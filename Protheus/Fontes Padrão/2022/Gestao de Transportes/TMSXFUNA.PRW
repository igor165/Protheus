#include "PROTHEUS.ch"
#include "TMSXFUNA.CH"
#include "FwMvcDef.CH"

Static lTMAFilRot := ExistBlock('TMAFILROT')   //-- 
Static lTMAAVERB  := ExistBlock('TMAAVERB')   //-- Averbacao por Valor da Mercadoria + Valor Adicional
Static lTMAAVBESP := ExistBlock('TMAAVBESP')  //-- Averbacao de um valor especifico
Static lTMAGRVSEG := ExistBlock('TMAGRVSEG')  //-- Executado apos a gravacao do DU7 (Averbacao de Seguro)
Static lGrvPed    := ExistBlock('TMAGRVPED')
Static lPedSC6    := ExistBlock('TMAPEDSC6')
Static lTMAFreCar := ExistBlock('TMAFRECAR')
Static lTMTABCAR  := ExistBlock('TMTABCAR')
Static lVer811    := ( nModulo == 43 )
Static lDU7Valor  := ( nModulo == 43 )
Static cProGen    := Padr(SuperGetMV('MV_PROGEN',,''),Len(SB1->B1_COD))
Static lPrdDiv    := SuperGetMV("MV_PRDDIV",,.F.) // Verifica se permitira a inclusao de um ou mais produtos
Static lPrcProd   := GetMV('MV_PRCPROD',,.T.)
Static lTMBRWCOL  := ExistBlock('TMBRWCOL')	//-- Permite ao usuario, incluir colunas no browse.
Static lTMPERCUB  := ExistBlock('TMPERCUB')
Static lTMSContrat:= ExistBlock('TMSCONTRAT')
Static lTMSBUTNF  := ExistBlock('TMSBUTNF')	//-- Ponto de Entrada permite manipular o Array de botoes na apresencao de todas as notas fiscais do documento.
Static lTMSSEGDC  := ExistBlock("TMSSEGDC")
Static lTMSPRZEN  := ExistBlock("TMSPRZEN")
Static lTMALTCLI  := ExistBlock("TMALTCLI")
Static lSF2520E   := Existblock("SF2520E")
Static lTMVALPDG  := Existblock("TMVALPDG")
Static lTMSTab    := ExistBlock("TMSTAB")
Static lTMALTTAB  := Existblock('TMALTTAB')
Static lTMNIVSUP  := Existblock('TMNIVSUP')
Static lTMSBasCtr := Existblock("TMSBASCT")
Static lDEGCalPdg := ( nModulo == 43 )
Static cTmpReg             //nome de arquivo temporario que contera hierarquia da regiao DUY
Static lTmpSup    := .F.  //controla se gerou arq temporario hierarquia Regiao DUY
Static aAuxPosic  := {}   //array para cache de Posicione
Static aSX5Tab63  := NIL   //array multidimensional com 3 elementos cada linha: dia , mes , ano
Static lSabFeri   := NIL   //leitura parametro MV_SABFERI
Static lDomFeri   := NIL   //leitura parametro MV_DOMFERI
Static lCxTabFer  := NIL   //indicativo se trabalha com cache da tabela DV8 - Feriados Municipais e tabela DWY - Feriados Regionais
Static aCxTabFer  := NIL   //cache da tabela de Feriados array multidimensional Posicao 1 - Feriados Municipais / Posicao 2 - Feriados Regionais
Static lTMSExp    := Nil
Static lTMSCFec   := Nil
Static __lBlind   := IsBlind()
Static lRestRepom := SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'
Static nMVHrPrz		:= SuperGetMV( "MV_TMSHPRZ", .F., 18 )	//-- horas uteis para calculo do prazo de entrega

Static cTMSERP    	:= SuperGetMV("MV_TMSERP",," ")	//-- Condição de integração com ERP (0 - Protheus, 1 - Datasul)
Static _oTabDVC
Static _oTabMae
Static _oVlFxDT1
Static _oVlFxDVD
Static _oVlFxDTG
Static _oNSupDUY

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSXFUNA  º Autor º        Nava        º Data º 18/10/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   Preenche aHeader e Acols da GetDados retornando Array de Gravacao    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º TMSFillGetDados( cAlias, nOrder, cSeekKey, bSeekWhile, ;  º±±
±±º            º                  bSeekFor, aNoFields, aYesFields,lOnlyYes)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                                           º±±
±±º         01 º nOpcx      - Opcao PADRAO do Mbrowse                      º±±
±±º         02 º cAlias     - Alias                                        º±±
±±º         03 º nOrder     - Ordem                                        º±±
±±º         04 º cSeekKey   - Chave de Seek para montar aCols              º±±
±±º         05 º bSeekWhile - Condicao While                               º±±
±±º         06 º bSeekFor   - Condicao For                                 º±±
±±º         07 º aNoFields  - Campos a serem excluidos                     º±±
±±º         08 º aYesFields - Campos a serem incluidos                     º±±
±±º         09 º lOnlyYes   - Flag indicando se considera somente os camposº±±
±±º            º declarados no aYesFields + campos do usuario              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º aColsRecno - Contem os Recno()'s que serao gravados       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º TMS - Gestao de Transportes                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º Supoe aHeader e Acols declarados como Private PELO progr. º±±
±±º            º e inicializadas como um array vazio.                      º±±
±±º            º O array do retorno contem todos os 'recno()' do arquivo   º±±
±±º            º que foi alterado/incluido. Portanto BASTA chamar a funcao º±±
±±º            º TMSRecGetD com este mesmo Array.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/02ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION TMSFillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, bSeekFor, aNoFields, aYesFields, lOnlyYes )

Local aArea			:= GetArea()
Local aAreaAlias	:= ( cAlias )->( GetArea() )
Local lNoFields		:= ( aNoFields  <> NIL )
Local lYesFields	:= ( aYesFields <> NIL )
Local aColsRecno	:= {}
Local aAuxHead		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aHeader e Acols devem vir definidos OBRIGATORIAMENTE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nUsado      := Len( aHeader )
Local nAux		  := 0
Local cCampo	  := ""
Local cUsado	  := ""
Local cArquivo	  := ""
Local cContext	  := ""
Local lAdd		  := .F.

DEFAULT nOrder	  := 1
DEFAULT bSeekFor  := { || .T. }
DEFAULT lOnlyYes  := .F.

// aHeader e aCols jah VEM PREECHIDOS OU VAZIO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aHeader para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aAuxHead	:= ApBuildHeader( cAlias , Iif( !lOnlyYes, Iif(!lNoFields, aNoFields , Nil ) , Nil ) )

For nAux := 1 To Len(aAuxHead)
	cCampo		:= aAuxHead[nAux,2]
	cUsado		:= GetSX3Cache(cCampo,'X3_USADO')
	cArquivo	:= GetSX3Cache(cCampo,'X3_ARQUIVO')
	cContext	:= GetSX3Cache(cCampo,'X3_CONTEXT')
	lAdd		:= .F.

	If lYesFields .And. Ascan( aYesFields, Rtrim( cCampo ) ) > 0
		lAdd 	:= .T.
	Else
		If lOnlyYes
			If GetSX3Cache(cCampo,'X3_PROPRI') == "U" .And. X3USO(cUsado) .And. cNivel >= GetSX3Cache(cCampo,'X3_NIVEL')
				lAdd	:= .T.
			EndIf
		Else
			If X3USO(cUsado) .And. cNivel >= GetSX3Cache(cCampo,'X3_NIVEL') .And. ( !lNoFields .Or. Ascan( aNoFields, Rtrim( cCampo ) ) = 0 )
				lAdd	:= .T.
			EndIf
		EndIf
	EndIf

	If lAdd
		AAdd(	aHeader, {	;
				Rtrim( aAuxHead[nAux,1] ), ;	//-- X3Titulo
				Rtrim( cCampo ),	; 			//-- X3_CAMPO
				aAuxHead[nAux,3], 	;			//-- X3_PICTURE
				aAuxHead[nAux,4], 	;			//-- X3_TAMANHO
				aAuxHead[nAux,5], 	;			//-- X3_DECIMAL
				RTrim( aAuxHead[nAux,6] ), 	;	//-- X3_VALID
				aAuxHead[nAux,7],	;			//-- X3_USADO
				aAuxHead[nAux,8], 	;			//-- X3_TIPO
				cArquivo,			;			//-- X3_ARQUIVO
				cContext		 })				//-- X3_CONTEXT

		++nUsado

	EndIf

Next nAux


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aCols para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

( cAlias )->( DbSetOrder( nOrder ) )
( cAlias )->( MsSeek( cSeekKey ) )

( cAlias )->( DbEval( {||	AAdd( aColsRecno, Recno() ), ;
									AAdd( aCols, Array( nUsado + 1 ) ), ;
									Aeval( aHeader, {|aCampo, nI|	aCols[Len(aCols),nI] := IF( aCampo[10] != 'V'.AND.nOpcx<>3,;
																				FieldGet(FieldPos(aHeader[nI,2])), ;
																				CriaVar(aHeader[nI,2],.T.) )  } ),;
									aCols[Len(aCols),nUsado+1]:=.F. },;
									bSeekFor,;
								{||!Eof() .And. Eval( bSeekWhile ) == cSeekKey } )	)

If ( Empty(aCols) ) // Coloca ao menos 1 em branco para a Inclusao ...
	AAdd(aCols,Array(nUsado+1))
	Aeval( aHeader, {|aCampo, nI| aCols[1][nI] := ( cAlias )->( CriaVar(aHeader[nI,2],.T.) ) } )
	aCols[Len(aCols)][nUsado+1] := .F.
EndIf

RestArea( aAreaAlias )
RestArea( aArea )

Return( aColsRecno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSXFUNA  º Autor º        Nava        º Data º 18/10/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º      Grava a Getdados a partir da aColsRecno gerado na TMSFillGetDados º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º TMSRecGetDados( cAlias, aColsRecno, aHeader, aCols, ;     º±±
±±º            º                 bRecFields, aNoEmptyFields )              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º Nenhum                                                    º±±
±±º         01 º cAlias     - Alias                                        º±±
±±º         02 º aColsRecno - Vetor gerado pela TMSFillGetD                º±±
±±º         03 º aHeader    - aHeader                                      º±±
±±º         04 º aCols      - aCols jah gravado.                           º±±
±±º         05 º bRecFields - Contem os campos a mais a serem gravados     º±±
±±º         06 º aNoEmptyFi - Campos que se forem vazios pulam a gravacao  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º Generico                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º - No bRecFields complementa-se os campos que NAO ESTAO no º±±
±±º            º aCols EXCETO Filial que o programa JAH GRAVA.             º±±
±±º            º - no aNoEmptyFields coloca-se os campos que SIMULAM ser   º±±
±±º            º obrigatorios. Caso estes campos existam e estejam vazios, º±±
±±º            º a gravacao EH PULADA.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/02ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION TMSRecGetdados( cAlias, aColsRecno, aHeader, aCols, bRecFields, aNoEmptyFields )

Local aArea := GetArea()
Local nFilial
Local nPos
Local lEmpty
Local cEmptyField
Local ni

DEFAULT cAlias			:= Alias()
DEFAULT bRecFields		:= { || .T. }
DEFAULT aNoEmptyFields	:= {}

DbSelectArea( cAlias )

nFilial := Ascan( DbStruct(), { |aFieldStruct| "_FILIAL" $ aFieldStruct[1] } )

FOR nI := 1 TO Len( aCols )
	IF nI <= Len( aColsRecno )
		MsGoto( aColsRecno[nI] )
		RecLock( cAlias, .F.)
		IF aCols[nI, Len( aHeader ) + 1] // Deletado
			DbDelete()
			MsUnlock()
			LOOP
		ENDIF
	ELSE

		IF ! aCols[nI, Len( aHeader ) + 1]
			// Procura por algum campo vazio
			lEmpty := .F.
			Aeval( aNoEmptyFields, { |cField| 	cEmptyField := cField, ;
															nPos := Ascan( aHeader, { |aField| aField[2] = cEmptyField } ),;
															lEmpty := 	IF( !lEmpty .And. nPos > 0, ;
																			Empty( aCols[nI][nPos] ), lEmpty ) } )
			IF !lEmpty // Nao grava se campo que NAO DEVE SER EMPTY estiver vazio !
				RecLock( cAlias, .T.)
			ELSE
				LOOP
			ENDIF
		ELSE
			LOOP
		ENDIF
	ENDIF

	Aeval( aHeader, { | aField, nJ, nFieldPos | IF ( ( nFieldPos := FieldPos( aHeader[nJ, 2] ) ) > 0, ;
																FieldPut( nFieldPos, aCols[nI, nJ] ), NIL ) } )
	IF nFilial > 0
		FieldPut( nFilial, xFilial( cAlias ) )
	ENDIF

	Eval( bRecFields )
	MsUnlock()

NEXT nI

RestArea( aArea )

Return( NIL )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSXFUNA  º Autor º        Nava        º Data º XX/10/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º             Acerta o funcionamento do 'OBRIGAT' na GetDados            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º TMSObgGetD( oGetDados )                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º oGetDados - Objeto da GetDados                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º Generico                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º A Classe Getdados nao olha X3_RESERV, somente X3_OBRIGAT. º±±
±±º            º Esta funcao FORCA a GetDados a olhar AMBOS os campos.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/02ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION TMSObgGetDados( oGetDados )

oGetDados:aPosCol := {}

Aeval( aHeader, { | aField, nI | IF( TMSExistX3( aField[2] ) .And. ;
												( X3Obrigat(aField[2])), ;
												AAdd( oGetDados:APosCol, { X3Titulo(), nI } ), NIL ) } )
Return( NIL )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSXFUNA  º Autor º         Nava       º Data º 18/10/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º             Verifica Existencia de Campo no SX3                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º TMSExistX3( cCampo, lVirtual )                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                                           º±±
±±º         01 º cCampo   - Nome do Campo                                  º±±
±±º         02 º lVirtual - Procura APENAS Campo Virtual                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º .T. se encontrou                                          º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º Generico                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º Se lVirtual == .T., entao SOMENTE retorna TRUE se o campo º±±
±±º            º existir E FOR VISUAL                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/02ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION TMSExistX3( cCampo, lVirtual )
Local lRet	:= .F.

DEFAULT lVirtual := .F.

lRet 	:= ExistCpo("SX3",cCampo ,2 , , .F.)

If lRet
	If lVirtual
		If GetSX3Cache(cCampo, "X3_CONTEXT") == "V"
			lRet	:= .T.
		Else
			lRet	:= .F.
		EndIf
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSXFUNA  º Autor º      Nava          º Data º 25/10/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           Verifica se o Campo Existe na Base e se TMS estah ativo      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º TMSBaseField( cCampo, lIntTMS )                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                                           º±±
±±º         01 º cCampo   - Nome do Campo                                  º±±
±±º         02 º lIntTMS  - Verifica ou Nao se existe Integracao TMS       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º True se encontrou.                                        º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º Generico                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º Com o Alias do Campo, verifica NA BASE se o campo         º±±
±±º            º existe. Com lIntTMS = .F. NAO verifica integracao com TMS º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/02ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION TMSBaseField( cCampo, lIntTMS )

Local cAliasStru := Right( "S"+Left( cCampo, At( "_", cCampo ) - 1 ), 3 )

DEFAULT lIntTms  := .T.

Return(  Select( cAliasStru ) > 0 .And. ;
			! Empty( ( cAliasStru )->( FieldPos( Upper( Alltrim( cCampo ) ) ) ) ) .And. ;
         ( !lIntTMS .Or. GetMv( "INTTMS",, .F. ) ) )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSValidEmp³ Autor ³ Patricia A. Salomao  ³ Data ³12.11.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verif. existencia da Filial                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSValidEmp(ExpC1)                                      	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 := Chave(Cod.Empresa+Cod.Filial)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION TMSValidEmp(cChave)

Local aArea		:= GetArea()
Local lRet 		:= .T.

DbSelectArea("SM0")
DbSetOrder(1)
If !MsSeek(cChave)	// Procura pelo Numero da Empresa e Filial.
	Help(" ",1,"TMSXFUNA01") //"Filial Digitada Invalida"
	lRet := .F.
EndIf
//-- Retorna para a Empresa+Filial Anterior
MsSeek(cEmpAnt+cFilAnt)
RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSPesqRegiao³ Autor ³ Alex Egydio        ³ Data ³20.11.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta a Estrutura de Regioes TMS                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSPesqRegiao(ExpC1,ExpC2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome da variavel que recebera o codigo da regiao   ³±±
±±³          ³         selecionada pelo usuario. (Obrigatorio)            ³±±
±±³          ³ ExpC2 = Nome da variavel que recebera a descricao da regiao³±±
±±³          ³         selecionada pelo usuario. (Obrigatorio)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Codigo da regiao                                           ³±±
±±³          ³ Descricao da regiao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Esta funcao sera utilizada para preenchimento do codigo e  ³±±
±±³          ³ Descricao da regiao, selecionada pelo usuario.             ³±±
±±³          ³                                                            ³±±
±±³          ³ Digitando uma regiao, cidade ou parte da descricao, sera   ³±±
±±³          ³ apresentado a estrutura de regioes.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION TMSPesqRegiao(cCodigo,cRegiao)

Local aAreaAnt	:= GetArea()
Local aAreaDUY	:= DUY->(GetArea())
Local aSizeAut	:= MsAdvSize( .F. )
Local aObjects	:= {}
Local aInfo		:= {}
Local aObj		:= {}
Local aRecnoDUY	:= {}
Local cGrupo	:= ''
Local nTamStr	:= 0
Local nOpca		:= 1
Local oDlg
Local oMenu

Private cCadastro	:= STR0007 //'Estrutura de Regioes'
Private oTree

PutHelp("PTMSXFUNA36",{"Regiao não encontrada (DUY)."},{"Area not found (DUY)"},{"Región no encontrada (DUY)"},.F.)

DEFAULT cCodigo	:= ''
DEFAULT cRegiao	:= ''

//-- Eh obrigatorio a passagem destes parametros.
If Empty( cCodigo ) .Or. Empty( cRegiao )
	Return( .F. )
EndIf

//-- Guarda string digitada pelo usuario.
cGrupo := &(ReadVar())
nTamStr:= Len( AllTrim( cGrupo ) )

//-- Verifica se ha regioes com esta string.
DUY->( DbSetOrder( 3 ) )
DUY->( MsSeek( xFilial('DUY') + AllTrim( cGrupo ), .F. ) )

While DUY->( !Eof() .And. DUY->DUY_FILIAL + PadR( DUY->DUY_DESCRI, nTamStr ) == xFilial('DUY') + AllTrim( cGrupo ) )

	If	!Empty( DUY->DUY_GRPSUP )
		AAdd( aRecnoDUY, DUY->( RecNo() ) )
	EndIf

	DUY->( DbSkip() )
EndDo

If	Empty( aRecnoDUY )
	Help(' ', 1, 'TMSXFUNA36') //"Regiao nao encontrada (DUY)."
	RestArea(aAreaDUY)
	RestArea(aAreaAnt)
	Return( .F. )
ElseIf Len( aRecnoDUY ) == 1
	//-- Se achou apenas uma descricao, referente a string digitada pelo usuario,
	//-- retorna o codigo e descricao sem apresentar o Tree.
	//-- Posiciona na regiao referente a string digitada pelo usuario.
	DUY->( DbGoto( aRecnoDUY[ 1 ] ) )
	M->&(cCodigo) := DUY->DUY_GRPVEN
	M->&(cRegiao) := DUY->DUY_DESCRI
	RestArea(aAreaDUY)
	RestArea(aAreaAnt)
	Return( .T. )

EndIf
//-- Controle de dimensoes dos objetos.
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, {  70, 100, .F., .T. } )

aInfo := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3 }
aObj  := MsObjSize( aInfo, aObjects, , .T. )

DEFINE MSDIALOG oDlg FROM aSizeAut[7],00 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL
oTree := DbTree():New( aObj[1,1], aObj[1,2], aObj[1,3], aObj[1,4],oDlg,,,.T.)
oTree:LShowHint := .F.

MENU oMenu POPUP
	MENUITEM STR0008 Action TMA120Pesq( @oTree )	//"Pesquisar"
	MENUITEM STR0009 Action TmsA120Leg()			//"Legenda"
ENDMENU

oTree:bRClicked  := { |o,x,y| oMenu:Activate( x, y, oTree )  }
//-- Ao clicar em uma pasta, preenche o codido e descricao da regiao.
oTree:bLClicked  := { || TMSPESQVar( oTree, cCodigo, cRegiao ) }
//-- Botao OK.
DEFINE SBUTTON FROM aObj[2,1] + 7, aObj[2,4] - 65 TYPE 1 ENABLE OF oDlg ACTION ( nOpca := 1, oDlg:End() )
//-- Botao Cancela.
DEFINE SBUTTON FROM aObj[2,1] + 7, aObj[2,4] - 33 TYPE 2 ENABLE OF oDlg ACTION ( nOpca := 0, oDlg:End() )

//-- Processa a construcao do Tree.
Processa( { || TMSPESQMnt( 'MAINGR', aRecnoDUY ) }, , STR0010 ) //"Construindo estrutura..."

ACTIVATE MSDIALOG oDlg

RestArea(aAreaDUY)
RestArea(aAreaAnt)

Return( nOpca == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSNivSup³ Autor ³ Alex Egydio           ³ Data ³09.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Niveis superiores da regiao.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSNivSup(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da regiao                                   ³±±
±±³          ³ ExpL1 = Adiciona no vetor todas as informacoes da Regiao   ³±±
±±³          ³ ExpL2 = Se for regiao coligada, despreza as regioes superio³±±
±±³          ³         res (Reg.Operacional) ?                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Vetor contendo os niveis superiores da regiao              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsNivSup( cRegiao ,lCompleto, lRegCol, aRegDUY, aCodCli )
Local aRet      := {}
Local cGrupo    := ''
Local cAliasQry := GetNextAlias()
Local cNomeFunc := ''
Local cTpExec   := ''
Local aSubReg   := {}

Default cRegiao		:= ""
Default lCompleto	:= .F.
Default lRegCol		:= .F.
Default aRegDUY		:= {}
Default aCodCli		:= {}

aRet := GetNivSup( cRegiao ,lCompleto, lRegCol, aRegDUY )

If Len(aRet) == 0
	//-- Obs: a funcao TMSCalFret() passa o parametro lRegCol como .T.; Isto porque, se a regiao (cRegiao) for coligada,
	//-- o preco deve ser verificado apenas nas regioes em que ela e' coligada; Ex: Suponhamos que uma Regiao esteja abaixo
	//-- do Estado de Tocantins e seja coligada ao Estado do Para; O sistema nao devera' procurar tabela de preco no
	//-- Estado de Tocantins (Reg.Operacional) e sim no Estado do Para' (Reg. Comercial).
	AADD(aRet,If(lCompleto,{DUY->DUY_GRPSUP,cRegiao,DUY->DUY_DESCRI,DUY->DUY_CDRCOL,DUY->DUY_CATGRP},cRegiao))

		//-- Adiciono os niveis superiores no vetor aRet.
		DUY->(DbSetOrder(1))
		If	DUY->( MsSeek(xFilial('DUY')+cRegiao))
			aAdd( aRegDUY, DUY->(Recno()) )
			If lRegCol .And. !Empty(DUY->DUY_CDRCOL)
				cGrupo := DUY->DUY_CDRCOL
			Else
				cGrupo := DUY->DUY_GRPSUP
			EndIf
			While !Empty(cGrupo) .And. cGrupo <> "MAINGR"
				If _oNSupDUY == Nil

					_oNSupDUY 	:= FwPreparedStatement():New()

					cQuery := "SELECT DUY_GRPVEN,DUY_DESCRI,DUY_CDRCOL,DUY_CATGRP,DUY_GRPSUP, R_E_C_N_O_ RECDUY "
					cQuery += " FROM " + RetSqlName("DUY")
					cQuery += " WHERE DUY_FILIAL 	= ? "
					cQuery += " AND DUY_GRPVEN 		= ?"
					cQuery += " AND D_E_L_E_T_ 		= ' '"
					cQuery := ChangeQuery(cQuery)

					_oNSupDUY:SetQuery(cQuery)
				EndIf

				_oNSupDUY:SetString(1,xFilial("DUY"))
				_oNSupDUY:SetString(2,cGrupo)

				cQuery := _oNSupDUY:GetFixQuery()

				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				cGrupo := ""
				If (cAliasQry)->(!Eof())
					If lRegCol .And. !Empty((cAliasQry)->DUY_CDRCOL)
						cGrupo := (cAliasQry)->DUY_CDRCOL
					Else
						cGrupo := (cAliasQry)->DUY_GRPSUP
					EndIf
					If	!Empty(cGrupo) .And. cGrupo <> cRegiao
						AAdd( aRet, If(lCompleto,{cGrupo,(cAliasQry)->DUY_GRPVEN,(cAliasQry)->DUY_DESCRI,(cAliasQry)->DUY_CDRCOL,(cAliasQry)->DUY_CATGRP},(cAliasQry)->DUY_GRPVEN))
						aAdd( aRegDUY, (cAliasQry)->RECDUY )
					EndIf
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndDo
		EndIf

	SetNivSup( cRegiao ,lCompleto, lRegCol, aRet, aRegDUY)
EndIf

	If lTMNIVSUP
		//Função:   Código:       Origem da Chamada
		//TMSA144       01        Viagem
		//TMSA146		  02	     Programação de Carregamento
		//TMSA200       03        Calculo do Frete
		//TMSA210       04        Manutenção de Carregamento
		//TMSA240       05        Complemento de Viagem
		//TMSA320       06        Geração de AWB
		//TMSA940       07        Grade Horario de Voo
		//TMSAW10       08        Proposta Comercial
		//TMSA050       09        Entrada NF Cliente
		//TMSA040       10        Cotação de Frete
		//		         " "       Outros

		cNomeFunc := FunName()
		Do Case
			CASE cNomeFunc = "TMSA144" //  01  Viagem
				cTpExec := "01"
          CASE cNomeFunc = "TMSA146" //  02	  Programação de Carregamento
				cTpExec := "02"
          CASE cNomeFunc = "TMSA200" //  03	  Calculo do Frete
				cTpExec := "03"
          CASE cNomeFunc = "TMSA210" //  04	  Manutenção de Carregamento
				cTpExec := "04"
          CASE cNomeFunc = "TMSA240" //  05	  Complemento de Viagem
				cTpExec := "05"
          CASE cNomeFunc = "TMSA320" //  06	  Geração de AWB
				cTpExec := "06"
          CASE cNomeFunc = "TMSA940" //  07	  Grade Horario de Voo
				cTpExec := "07"
          CASE cNomeFunc = "TMSAW10" //  08	  Proposta Comercial
				cTpExec := "08"
          CASE cNomeFunc = "TMSA050" //  09	  Entrada NF Cliente
				cTpExec := "09"
          CASE cNomeFunc = "TMSA040" //  10	  Cotação de Frete
				cTpExec := "10"
          OTHERWISE
				cTpExec := "  " // Outros
		EndCase
		aSubReg := ExecBlock('TMNIVSUP',.F.,.F.,{cRegiao,lRegCol,aCodCli,cTpExec,cNomeFunc,aRet})
		If ValType(aSubReg) = "A"
			If !Empty(aSubReg)
				aRet := aSubReg
			EndIf
		EndIf
	EndIf
Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SetNivSup ³ Autor ³ Adalberto S.M         ³ Data ³13.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adicionar informacoes dos niveis superios da regiao, funcao ³±±
±±³          ³TmsNivSup() ao vetor aTmsNivSup                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SetNivSup()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da regiao                                   ³±±
±±³          ³ ExpL1 = Adiciona no vetor todas as informacoes da Regiao   ³±±
±±³          ³ ExpL2 = Se for regiao coligada, despreza as regioes superio³±±
±±³          ³         res (Reg.Operacional) ?                            ³±±
±±³          ³ ExpA1 = Vetor contendo os Niveis Superiores da Regiao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetNivSup( cRegiao ,lCompleto, lRegCol, aNivSup, aRegDUY)
	Default aNivSup	:= {}
	Default cRegiao	:= ""

	If ValType(aTmsNivSup) <> 'A'
		Static aTmsNivSup := {}
	EndIf

    //////////////////////////////////////////////////////////////////////////
    // Manter o vetor aNivSup sempre na ultima posicao do vetor aTmsNivSup, //
    // para que a funcao GetNivSup() funcione corretamente.                 //
    //////////////////////////////////////////////////////////////////////////
	If Len(aNivSup) > 0
		Aadd( aTmsNivSup, { cRegiao ,lCompleto, lRegCol, aNivSup, aRegDUY } )
	EndIf
Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetNivSup ³ Autor ³ Adalberto S.M         ³ Data ³12.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Requisitar informacoes dos niveis superiores da regiao      ³±±
±±³          ³existentes no vetor aTmsNivSup. O intuito dessa rotina eh   ³±±
±±³          ³reaproveitar as informacoes ja processadas pela funcao      ³±±
±±³          ³TmsNivSup()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GetNivSup()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da regiao                                   ³±±
±±³          ³ ExpL1 = Adiciona no vetor todas as informacoes da Regiao   ³±±
±±³          ³ ExpL2 = Se for regiao coligada, despreza as regioes superio³±±
±±³          ³         res (Reg.Operacional) ?                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Vetor contendo os niveis superiores da regiao              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetNivSup( cRegiao ,lCompleto, lRegCol, aRegDUY )
	Local aRetorno	:= {}
	Local nPosicao	:= 0
	Default cRegiao	:= ""

	If ValType(aTmsNivSup) <> 'A'
		Static aTmsNivSup := {}
	EndIf

	If Len(aTmsNivSup) > 0
		aRetorno := {}
		nPosicao := Ascan( aTmsNivSup, { |x| x[1] == cRegiao .And. x[2] == lCompleto .And. x[3] == lRegCol } )

		If nPosicao > 0
			aRetorno := aTmsNivSup[ nPosicao, 4 ]  //PENULTIMA COLUNA
			aRegDUY  := aTmsNivSup[ nPosicao, 5 ]  //ULTIMA COLUNA
		EndIf
	EndIf
Return ( aRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSPESQMnt³ Autor ³ Alex Egydio           ³ Data ³20.11.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao auxiliar de TMSPesqRegiao(), que monta o Tree com a ³±±
±±³          ³ estrutura de regioes.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do DBTree.                                  ³±±
±±³          ³ ExpC1 = Cargo do tree.                                     ³±±
±±³          ³ ExpA1 = Numero dos registros que contem a String digitada  ³±±
±±³          ³         pelo usuario.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Procura no arquivo de estrutura de regioes, as regioes que ³±±
±±³          ³ contenham a string digitada pelo usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSPESQMnt( cCargo, aRecnoDUY )

Local aAreaAnt		:= GetArea()
Local aAreaDUY		:= DUY->( GetArea() )
Local aRegSup		:= {}
Local aRegiao		:= {}
Local aTodasReg		:= {}
Local nAchou		:= 0
Local cPasta		:= ''
Local nCntFor		:= 0
Local nCnt1			:= 0
Local nCnt			:= 0
//-- Obtem os grupos superiores.
DUY->( DbSetOrder( 1 ) )
ProcRegua(Len( aRecnoDUY ))
For nCntFor := 1 To Len( aRecnoDUY )
	IncProc()
	DUY->( DbGoto( aRecnoDUY[ nCntFor ] ) )
	If	! Empty( DUY->DUY_GRPSUP )
		aRegSup:={};aRegiao:={}
		aRegSup := TmsNivSup( DUY->DUY_GRPVEN ,.T.)
		// Estrutura de cada linha do array aRegSup com o parametro para retornar informacao completa
		// [DUY->DUY_GRPSUP,DUY->DUY_GRPVEN,DUY->DUY_DESCRI,DUY->DUY_CDRCOL,DUY->DUY_CATGRP]
		If	!Empty( aRegSup )
			For nCnt1 := Len( aRegSup ) to 1 Step -1
				AAdd( aRegiao, aRegSup[ nCnt1 ] )
			Next
		EndIf
		nAchou:=Ascan( aTodasReg, {|x| x[1,2] == aRegiao[1,2]})
		If	nAchou == 0
			AAdd(aTodasReg,aRegiao)
		ElseIf nAchou > 0 .And. Len(aTodasReg[nAchou]) < Len(aRegiao)
			ADEL(aTodasReg,nAchou)
			aTodasReg[Len(aTodasReg)]:=ACLONE(aRegiao)
		EndIf
	EndIf
Next
aSort( aTodasReg,,,{|x,y| x[1,2] < y[1,2]})
// Monta tree na primeira vez
oTree:BeginUpdate()
oTree:Reset()
oTree:EndUpdate()
oTree:AddTree(PadR(STR0011,100),.T.,,,"FOLDER5","FOLDER5",cCargo) //"Estrutura de Regioes"
DUY->( DbSetOrder( 1 ) )
//-- Monta o Tree com a estrutura de regioes.
ProcRegua(Len( aTodasReg ))
For nCntFor := 1 To Len(aTodasReg)
	IncProc()
	For nCnt :=1 to Len(aTodasReg[nCntFor])
		// Estrutura de cada linha do array aRegSup com o parametro para retornar informacao completa
		// [DUY->DUY_GRPSUP,DUY->DUY_GRPVEN,DUY->DUY_DESCRI,DUY->DUY_CDRCOL,DUY->DUY_CATGRP]
		//-- Monta a descricao da pasta.
		cPasta := PadR(aTodasReg[nCntFor,nCnt,2]+'-'+Capital(aTodasReg[nCntFor,nCnt,3])+Iif(Empty(aTodasReg[nCntFor,nCnt,4]),'',Space(10) + '(' + STR0012 +aTodasReg[nCntFor,nCnt,4]+')'), 100 ) //"Coligada a Regiao: "
		//-- Adiciona nova pasta ao Tree.
		If	aTodasReg[nCntFor,nCnt,5] == StrZero(1,Len(DUY->DUY_CATGRP))
			If nCnt = Len(aTodasReg[nCntFor])
				oTree:AddTreeItem(cPasta,"FOLDER10","FOLDER11",aTodasReg[nCntFor,nCnt,2])
			Else
				oTree:AddTree(cPasta,.T.,,,"FOLDER10","FOLDER11",aTodasReg[nCntFor,nCnt,2])
			EndIf
		ElseIf aTodasReg[nCntFor,nCnt,5] == StrZero(2,Len(DUY->DUY_CATGRP))
			If nCnt = Len(aTodasReg[nCntFor])
				oTree:AddTreeItem(cPasta,"FOLDER12","FOLDER13",aTodasReg[nCntFor,nCnt,2])
			Else
				oTree:AddTree(cPasta,.T.,,,"FOLDER12","FOLDER13",aTodasReg[nCntFor,nCnt,2])
			EndIf
		ElseIf aTodasReg[nCntFor,nCnt,5] == StrZero(3,Len(DUY->DUY_CATGRP))
			If nCnt = Len(aTodasReg[nCntFor])
				oTree:AddTreeItem(cPasta,"FOLDER5","FOLDER6",aTodasReg[nCntFor,nCnt,2])
			Else
				oTree:AddTree(cPasta,.T.,,,"FOLDER5","FOLDER6",aTodasReg[nCntFor,nCnt,2])
			EndIf
		EndIf
	Next nCnt
	For nCnt :=1 to Len(aTodasReg[nCntFor]) -1
		oTree:EndTree()
	Next nCnt
Next nCntFor

oTree:EndTree()
RestArea(aAreaDUY)
RestArea(aAreaAnt)

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSPESQVar³ Autor ³ Alex Egydio           ³ Data ³20.11.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao auxiliar de TMSPesqRegiao(), que preenche o codigo  ³±±
±±³          ³  e descricao da regiao selecionada pelo usuario no tree.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do DBTree.                                  ³±±
±±³          ³ ExpC1 = Nome da variavel que recebera o codigo da regiao   ³±±
±±³          ³         selecionada pelo usuario. (Obrigatorio)            ³±±
±±³          ³ ExpC2 = Nome da variavel que recebera a descricao da regiao³±±
±±³          ³         selecionada pelo usuario. (Obrigatorio)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSPESQVar( oTree, cCodigo, cRegiao )

Local cGrupo := oTree:GetPrompt()

M->&(cCodigo) := Left( cGrupo, Len( DUY->DUY_GRPVEN ) )
M->&(cRegiao) := Subs( cGrupo, Len( DUY->DUY_GRPVEN ) + 2, Len( DUY->DUY_DESCRI ) )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSABrowse³ Autor ³ Richard Anderson      ³ Data ³20.11.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Selecao de Itens em um Array                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array dos Itens                                    ³±±
±±³          ³ ExpC1 = Título da Dialog                                   ³±±
±±³          ³ ExpB1 = Bloco de codigo a ser executada a cada selecao     ³±±
±±³          ³ ExpL1 = Identifica se o bloco de codigo deve ser executado ³±±
±±³          ³         na ativacao da Dialog                              ³±±
±±³          ³ ExpL2 = Permite ou nao que o retorno possa ocorrer sem     ³±±
±±³          ³         itens selecionados                                 ³±±
±±³          ³ ExpL3 = Identifica se a selecao ocorrera sempre de um em   ³±±
±±³          ³         um item                                            ³±±
±±³          ³ ExpA1 = Array contendo a descricao da 1a e da 2a coluna    ³±±
±±³          ³ ExpA2 = Array contendo a cabecalho Complementar            ³±±
±±³          ³ ExpA3 = Array contendo a cpos a serem exibidos complementar³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSABrowse(aList,cTitulo,bAcao,lIniAcao,lNaoItem,lOpcao,aCabec,aCabCom,aListCom)

Local nElem
Local oListBox, oDlg
Local aListAux   := Aclone(aList)
Local lValido    := .F.
Local nOpc       := 0
Local aTitulo    := { " ", STR0013 , STR0014 } //"Codigo"###"Descricao"
Local lMarcaItem := .T.
Local lUmaOpcao  := lOpcao
Local nCnt       := 0
Local aHList     := {}
Local aUsHList   := {}

PutHelp("PTMSXFUNA37",{"Deve ser selecionado um item"},{"Item must be selected"},{"Debe seleccionarse un ítem"},.F.)

If bAcao != NIL .And. ValType(bAcao) != "B"
   bAcao := NIL
EndIf

If lIniAcao == NIL
   lIniAcao := .F.
EndIf

If lNaoItem == NIL
   lNaoItem := .F.
EndIf

//-- se informado cabecalho
If aCabec != NIL
	aTitulo := { " " }
	For nCnt := 1 To Len(aCabec)
		AAdd( aTitulo, aCabec[nCnt] )
	Next nCnt
EndIf

lUmaOpcao := If( lUmaOpcao == NIL, .F., lUmaOpcao )

WHILE .T.

	//-- Header
	For nCnt := 1 To Len(aTitulo)
		AAdd( aHList, aTitulo[nCnt] )
	Next nCnt

	//-- Inclui colunas do usuario
	If lTMBRWCOL
		If ValType( aUsHList := ExecBlock( 'TMBRWCOL', .F., .F., { aList } ) ) <> 'A'
			aUsHList := {}
		EndIf
		If Len(aUsHList) == 2 .And. ValType(aUsHList[1]) == "A" .And. ValType(aUsHList[2]) == "A"
			aList := aClone(aUsHList[1])
			For nCnt := 1 To Len(aUsHList[2])
				AAdd( aHList, aUsHList[2,nCnt] )
			Next nCnt
		Else
			aUsHList := {}
		EndIf
	EndIf

	DEFINE MSDIALOG oDlg TITLE cTitulo From 150,200 To 600,800 OF oMainWnd PIXEL

	oListBox := TWBrowse():New( 05,10,250,215, NIL, aHList, NIL, oDlg, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
	oListBox:bLDblClick  := { || (If(lUmaOpcao,Aeval(aList,{|aElem|aElem[1] := .F.}),AllWaysTrue()), aList[oListBox:nAt,1] := !aList[oListBox:nAt,1],If(bAcao!=NIL,Eval(bAcao),),oListBox:Refresh()) }
	oListBox:SetArray( aList )
	oListBox:bLine := &('{ || TmsBrwbLin(oListBox:nAT,aList,aUsHList,aListCom) }')

	DEFINE SBUTTON FROM 03,268 TYPE 1 ACTION (nOpc := 1,oDlg:End()) ENABLE OF oDlg PIXEL
	DEFINE SBUTTON FROM 18,268 TYPE 2 ACTION (nOpc := 0,oDlg:End()) ENABLE OF oDlg PIXEL

	If !lUmaOpcao
		DEFINE SBUTTON FROM 32,268 TYPE 11 ACTION (Aeval(aList,{|aElem|aElem[1] := lMarcaItem}), lMarcaItem := !lMarcaItem,If(bAcao==NIL,,Eval(bAcao)),oListBox:Refresh()) ONSTOP STR0015 ENABLE OF oDlg //"Marca/Desmarca"
		@ 47,268 BUTTON STR0008 ACTION TMSPesqBrw(aList,aTitulo,oListBox) SIZE 26,11 OF oDlg PIXEL //"Pesquisar"
	Else
		@ 32,268 BUTTON STR0008 ACTION TMSPesqBrw(aList,aTitulo,oListBox) SIZE 26,11 OF oDlg PIXEL //"Pesquisar"
	EndIf

	If bAcao != NIL .And. lIniAcao
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval(bAcao)
	Else
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

	If nOpc == 0
		Aeval(aList,{|aElem,nCount|aElem[1] := aListAux[nCount,1]})
		lValido := .T.
	Else
		If lNaoItem
			lValido := .T.
		Else
			For nElem := 1 To Len(aList)
				If aList[nElem,1]
					lValido := .T.
					Exit
				EndIf
			Next
		EndIf
	EndIf

	If lValido
		Exit
	Else
		Help(" ",1,"TMSXFUNA37") //"Deve ser selecionado um item"
	EndIf
EndDo

Return( nOpc==1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSGeraNFS³ Autor ³ Alex Egydio           ³ Data ³23.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera nota fiscal de saida a partir do SIGATMS.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do pedido de venda.                         ³±±
±±³          ³ ExpC2 = Serie do documento TMS.                            ³±±
±±³          ³ ExpC3 = Codigo do cliente.                                 ³±±
±±³          ³ ExpC4 = Loja do cliente.                                   ³±±
±±³          ³ ExpA1 = Sera preenchido com pedidos com bloqueio de credito³±±
±±³          ³ ExpB1 = Code Block para gravacao do conhecimento           ³±±
±±³          ³ ExpB2 = Code Block para atualizacao do pedido de venda     ³±±
±±³          ³         antes da geracao do documento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Numero da nota fiscal de saida.                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSGeraNFS( cPedido, cSerie, cCliente, cLoja, aPedido, bA200Atu, bA200Pvl, bFatSE1, aMsgErr )
Local aAreaAnt    := GetArea()
Local aAreaSC5    := SC5->( GetArea() )
Local aAreaSC6    := SC6->( GetArea() )
Local aAreaSC9    := SC9->( GetArea() )
Local aAreaSE4    := SE4->( GetArea() )
Local aAreaSB1    := SB1->( GetArea() )
Local aAreaSB2    := SB2->( GetArea() )
Local aAreaSF4    := SF4->( GetArea() )
Local aPvlNfs     := {}
Local cNumNFS     := ''
Local nRegDAK     := 0
Local lMostraCtb  := .F.
Local lAglutCtb   := .F.
Local lCtbOnLine  := .F.
Local lCtbCusto   := .F.
Local lReajuste   := .F.
Local lAtuSA7     := .F.
Local lECF        := .F.
Local nPrcVen     := 0
Local nCalAcrs    := 1
Local nArredPrcLis:= 1
Local cQuery      := ""
Local cAliasQry   := ""

DEFAULT aPedido   := {}
DEFAULT bA200Atu  := {||.T.}
DEFAULT bA200Pvl  := {||.T.}
DEFAULT aMsgErr   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 Imprime Lote apos o calculo ?  Sim/Nao               ³
//³ mv_par02 Transmite CT-e              ?  Sim/Nao               ³
//³ mv_par03 Aglut. Lan‡amentos          ?  Sim/Nao               ³
//³ mv_par04 Lan‡.Contab.On-Line         ?  Sim/Nao               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lMostraCtb	:= .F.
lAglutCtb	:= .F.
lCtbOnLine	:= .F.
lCtbCusto	:= .F.
lReajuste	:= .F.

Pergunte('TMB200',.F.)
lAglutCtb  := mv_par03 == 1
lCtbOnLine := mv_par04 == 1


//-- Somente sera faturado se todos os itens do pedido estiverem liberados.
SC9->(DbSetOrder(2)) //C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
cAliasQry := GetNextAlias()
cQuery := "   SELECT C9_LOTNFC, C9_PEDIDO, C9_ITEM, C9_BLCRED, C9_BLTMS, C9_CLIENTE, C9_LOJA, C9_PRODUTO, C9_QTDLIB, C9_PRCVEN, C9_SERVIC, C9_BLINF "
cQuery += "     FROM " + RetSqlName("SC9")
cQuery += "    WHERE C9_FILIAL  = '" + xFilial("SC9") + "' "
cQuery += "      AND C9_CLIENTE = '" + cCliente + "' "
cQuery += "      AND C9_LOJA    = '" + cLoja    + "' "
cQuery += "      AND C9_PEDIDO  = '" + cPedido  + "' "
cQuery += "      AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY " + SqlOrder(SC9->(IndexKey()))
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While (cAliasQry)->(!Eof())
	If	(!Empty((cAliasQry)->C9_BLCRED) .And. (cAliasQry)->C9_BLCRED != '10') .Or. (!Empty((cAliasQry)->C9_BLTMS))

	     //-- Descrição do bloqueio
          //--    C9_BLCRED:
          //--                01 - Bloqueio de Credito por Valor
          //--                04 - Vencto do Limite de Credito
          //--                05 - Bloqueio de Credito por Estorno
          //--                06 - Bloqueio de Credito por Risco
          //--                09 - Rejeicao de Credito

          //--    C9_BLTMS:
          //--                10 - Comercial
          //--                20 - Operacional
          _cC9_BLINF := (cAliasQry)->C9_BLINF
          If Empty(_cC9_BLINF)
                Do Case
                     Case (cAliasQry)->C9_BLCRED == "01"
                          _cC9_BLINF := "Bloqueio de Credito por Valor."
                     Case (cAliasQry)->C9_BLCRED == "04"
                          _cC9_BLINF := "Vencto do Limite de Credito."
                     Case (cAliasQry)->C9_BLCRED == "05"
                          _cC9_BLINF := "Bloqueio de Credito por Estorno."
                     Case (cAliasQry)->C9_BLCRED == "06"
                          _cC9_BLINF := "Bloqueio de Credito por Risco."
                     Case (cAliasQry)->C9_BLCRED == "09"
                          _cC9_BLINF := "Rejeicao de Credito."
                EndCase
          EndIf

	     //-- Monta Array com as informações do pedido que gerou bloqueado devido a limite de crédito.
		Aadd(aPedido, {	(cAliasQry)->C9_LOTNFC ,;
						(cAliasQry)->C9_PEDIDO ,;
						(cAliasQry)->C9_ITEM   ,;
						(cAliasQry)->C9_BLCRED ,;
						(cAliasQry)->C9_BLTMS  ,;
						(cAliasQry)->C9_CLIENTE,;
						(cAliasQry)->C9_LOJA   ,;
						My_Posicione('SA1', 1, xFilial('SA1') + (cAliasQry)->C9_CLIENTE + (cAliasQry)->C9_LOJA, 'A1_NREDUZ'),;
						(cAliasQry)->C9_PRODUTO,;
						(cAliasQry)->C9_QTDLIB ,;
						(cAliasQry)->C9_PRCVEN ,;
						(cAliasQry)->C9_SERVIC ,;
						 _cC9_BLINF } )


	EndIf
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

//-- Pedido com bloqueio.
If !Empty( aPedido )
	Begin Transaction
		//-- Atualizacao dos pedidos com bloqueios
		Eval( bA200Atu )
	End Transaction
	Return( cNumNFS )
EndIf

SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
cQuery := "   SELECT C6_NUM, C6_ITEM, C6_LOCAL, C6_PRODUTO, C5_MOEDA, C9_SEQUEN, C9_QTDLIB, C9_QTDLIB2, C9_PRCVEN, "
cQuery += "          SC5.R_E_C_N_O_ RECSC5, SC6.R_E_C_N_O_ RECSC6, SC9.R_E_C_N_O_ RECSC9, SF4.R_E_C_N_O_ RECSE4, "
cQuery += "          SF4.R_E_C_N_O_ RECSF4, SB1.R_E_C_N_O_ RECSB1, SB2.R_E_C_N_O_ RECSB2  "
cQuery += "   FROM "
cQuery += RetSqlName("SC5") + " SC5, "
cQuery += RetSqlName("SC6") + " SC6, "
cQuery += RetSqlName("SC9") + " SC9, "
cQuery += RetSqlName("SE4") + " SE4, "
cQuery += RetSqlName("SF4") + " SF4, "
cQuery += RetSqlName("SB1") + " SB1, "
cQuery += RetSqlName("SB2") + " SB2  "
cQuery += "   WHERE C5_FILIAL = '" + xFilial("SC5") + "' "
cQuery += "     AND C5_NUM    = '" + cPedido + "' "
cQuery += "     AND SC5.D_E_L_E_T_ = ' ' "
//-- Itens dos Pedidos de Vendas
cQuery += "     AND C6_FILIAL = '" + xFilial("SC6") + "' "
cQuery += "     AND C6_NUM    = '" + cPedido + "' "
cQuery += "     AND SC6.D_E_L_E_T_ = ' ' "
//-- Pedidos de Vendas Liberados
cQuery += "     AND C9_FILIAL = '" + xFilial("SC9") + "' "
cQuery += "     AND C9_PEDIDO = '" + cPedido + "' "
cQuery += "     AND C9_ITEM   = C6_ITEM"
cQuery += "     AND SC9.D_E_L_E_T_ = ' ' "
//-- Condicoes de Pagamento
cQuery += "     AND E4_FILIAL = '" + xFilial("SE4") + "' "
cQuery += "     AND E4_CODIGO = C5_CONDPAG"
cQuery += "     AND SE4.D_E_L_E_T_ = ' ' "
//-- Cadastro de TES
cQuery += "     AND F4_FILIAL = '" + xFilial("SF4") + "' "
cQuery += "     AND F4_CODIGO = C6_TES"
cQuery += "     AND SF4.D_E_L_E_T_ = ' ' "
//-- Cadastro de Produtos
cQuery += "     AND B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "     AND B1_COD    = C6_PRODUTO"
cQuery += "     AND SB1.D_E_L_E_T_ = ' ' "
//-- Saldos Produtos
cQuery += "     AND B2_FILIAL = '" + xFilial("SB2") + "' "
cQuery += "     AND B2_COD   = C6_PRODUTO"
cQuery += "     AND B2_LOCAL = C6_LOCAL"
cQuery += "     AND SB2.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY " + SqlOrder(SC6->(IndexKey()))
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While (cAliasQry)->(!Eof())
	nPrcVen := (cAliasQry)->C9_PRCVEN
	If	(cAliasQry)->C5_MOEDA <> 1
		nPrcVen := xMoeda(nPrcVen,(cAliasQry)->C5_MOEDA,1,dDataBase)
	EndIf
	Aadd(aPvlNfs,{	(cAliasQry)->C6_NUM, (cAliasQry)->C6_ITEM, (cAliasQry)->C9_SEQUEN,;
					(cAliasQry)->C9_QTDLIB, nPrcVen, (cAliasQry)->C6_PRODUTO, .F.,;
					(cAliasQry)->RECSC9, (cAliasQry)->RECSC5, (cAliasQry)->RECSC6,;
					(cAliasQry)->RECSE4, (cAliasQry)->RECSB1, (cAliasQry)->RECSB2,;
					(cAliasQry)->RECSF4, (cAliasQry)->C6_LOCAL, nRegDAK, (cAliasQry)->C9_QTDLIB2 })
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

If	! Empty(aPvlNfs)
	//-- Inclusao de Nota fiscal de Saida atraves do PV liberado
	cNumNFS := MaPvlNfs(aPvlNfs,cSerie,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajuste,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,,,bA200Atu,bA200Pvl,bFatSE1)
EndIf

RestArea(aAreaSF4)
RestArea(aAreaSB2)
RestArea(aAreaSB1)
RestArea(aAreaSE4)
RestArea(aAreaSC9)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaAnt)

Return( cNumNFS )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSDelNFS³ Autor ³ Alex Egydio           ³ Data ³23.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Estorna nota fiscal de saida.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSDelNFS(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero da nota.                                    ³±±
±±³          ³ ExpC2 = Serie do documento TMS.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSDelNFS( cNumNFS, cSerie, lApaga )

Local aAreaSF2    := SF2->(GetArea())
Local aRegSD2     := {}
Local aRegSE1     := {}
Local aRegSE2     := {}
Local lRet        := .F.
Local lAglutCtb   := .F.
Local lCtbOnLine  := .F.

Default lApaga    := .T.

Pergunte('TMB200',.F.)
lAglutCtb  := mv_par03 == 1
lCtbOnLine := .T. //contabilizacao da exclusao sempre efetuar on line.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa processo de lançamento no modulo PCO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoIniLan("000101")
SF2->(DbSetOrder(1))
If	SF2->(MsSeek(xFilial("SF2") + cNumNFS + cSerie, .F.))
	//-- Verifica se o estorno do documento de saida pode ser feito.
	If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
		If lSF2520E
			ExecBlock("SF2520E",.F.,.F.)
		EndIf
		//-- Estorna o documento de saida.
		If lApaga
			SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,lAglutCtb,lCtbOnLine,.T.,,1))
		EndIf
		lRet := .T.
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza processo de lancamento no modulo PCO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoFinLan("000101")
RestArea(aAreaSF2)

Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSChkViag³ Autor ³ Alex Egydio           ³ Data ³01.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a situacao da viagem.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSChkViag()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de Origem                                   ³±±
±±³          ³ ExpC2 = Codigo da viagem                                   ³±±
±±³          ³ ExpL1 = .T. Verifica se a viagem esta em aberto            ³±±
±±³          ³ ExpL2 = .T. Verifica se ha manifesto                       ³±±
±±³          ³ ExpL3 = .T. Verifica se ha contrato de carreteiro          ³±±
±±³          ³ ExpL4 = .T. Emite help se houver restricoes                ³±±
±±³          ³ ExpL5 = .T. Travar o registro da viagem                    ³±±
±±³          ³ ExpL6 = .T. Verifica se ha complemento de viagem           ³±±
±±³          ³ ExpL7 = .T. Verifica se a viagem esta em transito          ³±±
±±³          ³ ExpL8 = .T. Verifica se viagem vazia                       ³±±
±±³          ³ ExpL9 = .T. Verifica se a viagem esta bloqueada            ³±±
±±³          ³ ExpA1 = .T. Vetor contendo as mensagens do Help            ³±±
±±³          ³ ExpL10= .T. Chegada Parcial ?                              ³±±
±±³          ³ ExpL11= .T. Verifica Viagem Encerrada ?                    ³±±
±±³          ³ ExpL12= .T. Verifica Viagem Fechada                        ³±±
±±³          ³ ExpL13= .T. Verifica se ha operacoes encerradas            ³±±
±±³          ³ ExpL14= .T. Verifica se a viagem esta cancelada            ³±±
±±³          ³ ExpL15= .T. Verifica se a viagem é planejada.              ³±±
±±³          ³ ExpL16= .T. Verifica se ha operacoes encerradas            ³±±
±±³          ³ ExpL17= .T. Verifica se a viagem esta cancelada            ³±±
±±³          ³ ExpL18= .T. Verifica se a viagem e planejada.              ³±±
±±³          ³ ExpC19= Filial Atual                                       ³±±
±±³          ³ ExpC20= .T. Gerar complemento de viagem vazio              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. = Nao houve restricoes para a viagem.                  ³±±
±±³          ³ .F. = Houve restricoes para a viagem.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Esta funcao sera utilizada para analisar se ha restricoes  ³±±
±±³          ³ para a viagem.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSChkViag(cFilOri, cViagem, lAberto, lManifesto, lContrato, lHelp, lTrava, lComplem, lTransito, lVazia, lBloqueio, aMsgErr, lChgParc, lEncerrada, lFechada, lOperacao, lCancelada, lPlanejada, cFilAtu, lCompVazio, cTipOco)

Local aAreaAnt		:= GetArea()
Local aAreaDTY		:= DTY->(GetArea())
Local aAreaDTX		:= DTX->(GetArea())
Local aAreaDTR		:= DTR->(GetArea())
Local aAreaDUC		:= DUC->(GetArea())
Local aAreaDTW		:= DTW->(GetArea())
Local lRet			:= .T.
Local lMsgErr		:= .F.
Local lMsgChg		:= .F.
Local lCarreg		:= .F.
Local cAliasDUD	:= GetNextAlias()
Local cQuery		:= ""
Local cSerAdi		:= ""
Local lF11RotRot	:= FindFunction('F11RotRote')
Local lVgeMod3      := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local lMv_TmsOcoL 	:= SuperGetMv("MV_TMSOCOL",.F.,.F.) //-- Permite informar a ocorrencia do documento de outra filial.

DEFAULT cFilOri  	:= cFilAnt
DEFAULT lAberto	    := .T.
DEFAULT lManifesto  := .T.
DEFAULT lContrato	:= .T.
DEFAULT lHelp		:= .T.
DEFAULT lTrava		:= .F.
DEFAULT lComplem	:= .F.
DEFAULT lTransito	:= .F.
DEFAULT lVazia		:= .F.
DEFAULT lBloqueio	:= .F.
DEFAULT aMsgErr		:= {}
DEFAULT lChgParc	:= .T.
DEFAULT lEncerrada  := .T.
DEFAULT lFechada	:= .F.
DEFAULT lOperacao	:= .F.
DEFAULT lCancelada  := .T.
DEFAULT lPlanejada  := .F.
DEFAULT cFilAtu     := cFilAnt
DEFAULT lCompVazio  := .F.
DEFAULT cTipOco		:= ""

//-- Indica se é um processo de retirada de mercadoria não prevista
If Type("lPrcMerNpr") == "U"
	Private lPrcMerNpr := .F.
EndIf
If lVgeMod3 .And. FindFunction('TF64GetSt')  //Atualiza a variavel private que não existe na Modelo3
	If TF64GetSt('nTipAltVia') <> 0   //Alteracao de Viagem em Transito
		lPrcMerNpr:= .T.
	EndIf
EndIf

lMsgErr := .T.
aMsgErr := {}

DTQ->(DbSetOrder(2))
If DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))
	// Verifica se existe documentos com Status Carregado na Viagem
	cQuery := " SELECT DUD_DOC "
	cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
	cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "   AND DUD_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DUD_VIAGEM = '" + cViagem + "' "
	If DTQ->DTQ_SERTMS != StrZero(2,Len(DTQ->DTQ_SERTMS))
		cQuery += " AND DUD_FILDOC = '" + cFilAnt + "' "
	Else
		cQuery += " AND DUD_FILATU = '" + cFilAnt + "' "
	EndIf
	cQuery += "   AND DUD_STATUS = '3' AND DUD.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasDUD, .F., .T. )

	lCarreg := !Empty((cAliasDUD)->DUD_DOC)

	(cAliasDUD)->(DbCloseArea())

	//-- Verifica se a viagem esta encerrada
	If lEncerrada .And. DTQ->DTQ_STATUS == StrZero(3,Len(DTQ->DTQ_STATUS))
		If lHelp
			Help(' ', 1, 'TMSXFUNA04')							//-- Viagem encerrada
		EndIf
		If lMsgErr
			AAdd( aMsgErr, {STR0017 + cViagem + STR0018 , '04' , 'TMSA140()'} ) //"Viagem "###" Encerrada."
		EndIf
		lRet := .F.
	EndIf
	//-- Verifica se a viagem esta cancelada
	If lRet .And. lCancelada .And. DTQ->DTQ_STATUS == StrZero(9,Len(DTQ->DTQ_STATUS))
		If lHelp
			Help(' ', 1, 'TMSXFUNA17')							//-- Viagem Cancelada
		EndIf
		If lMsgErr
			AAdd( aMsgErr, {STR0017 + cViagem + STR0019 , '04' , 'TMSA140()'} ) //"Viagem "###" Cancelada."
		EndIf
		lRet := .F.
	EndIf
	//-- Manutencoes permitidas somente na filial de origem
	If lRet .And. DTQ->DTQ_SERTMS != StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_FILATU  == DTQ->DTQ_FILORI .And.;
		( Iif((Left(FunName(),7) == "TMSA250"), cFilAtu!= DTQ->DTQ_FILDES, cFilAnt!=DTQ->DTQ_FILDES) )  //Parametro mv_par08 Filial Origem da Viagem
			If lHelp
				Help(' ', 1,'TMSXFUNA18',,DTQ->DTQ_FILDES,02,22) //-- Manutencoes nesta viagem, somente serao permitidas na filial
			EndIf
			If !lMv_TmsOcoL
				If lMsgErr
					AAdd( aMsgErr, { STR0020 + DTQ->DTQ_FILDES, '04' , 'TMSA140()'} ) //"Manutencoes nesta viagem, somente serao permitidas na filial "
				EndIf
				lRet := .F.
			EndIf
	EndIf
	//-- Trava o registro
	If	lRet .And. lTrava .And. DTQ->( ! MsRLock() )
		If lHelp
			Help(' ', 1, 'TMSXFUNA02') //-- Viagem em uso por outro usuario.
		EndIf
		If lMsgErr
			AAdd( aMsgErr, { STR0017 + cViagem + STR0021 , '01', 'TMSA140()' } ) //"Viagem "###" em Uso por outro usuario. "
		EndIf
		lRet := .F.
	EndIf

	//-- Verifica se a Viagem e Planejada.
	If	lRet .And. lPlanejada .And. DTQ->DTQ_TIPVIA == StrZero( 3, Len( DTQ->DTQ_TIPVIA ) ) .AND. !IsInCallStack("TMSA142")
		If lHelp
			Help(' ', 1, 'TMSXFUNA35') //-- Não é permitido fechar viagens do tipo - Planejada.
		EndIf
		If lMsgErr
			AAdd( aMsgErr, { STR0022 , '00', '' } ) //"Nao e permitido fechar viagens do tipo - Planejada."
		EndIf
		lRet := .F.
	EndIf

	If lRet .And. lAberto
		cSerAdi := DTQ->DTQ_SERADI
		If Empty(cSerAdi) .Or. cSerAdi == '0'
			//-- Execute pergunte para prever viagens que não possuem serviço adicional, porem passarão a ter
			Pergunte("TMB144",.F.)
			cSerAdi := mv_par02
		EndIf

		If DTQ->DTQ_STATUS == StrZero( 4, Len(DTQ->DTQ_STATUS)) // Quando o Status da viagem for em chegada em filial a viagem nao pode ser alterada, para a inclusao de novos documentos
			cSerAdi := '0'
		EndIf

		lOldFiles :=  IsInCallStack("TMSA240MNT") .Or. IsInCallStack("TmsA210Mnt") .Or. IsInCallStack("TMSA146")
		If DTQ->DTQ_STATUS != StrZero(1,Len(DTQ->DTQ_STATUS)) .And. DTQ->DTQ_SERTMS != StrZero(1,Len(DTQ->DTQ_SERTMS)) .And. cSerAdi != StrZero(1,Len(DTQ->DTQ_SERTMS)) .And. lOldFiles .And. !lCarreg
			//-- Verifica se houve a chegada da viagem na filial
			If lChgParc .And. DTQ->DTQ_STATUS == StrZero( 4, Len(DTQ->DTQ_STATUS) )
				If DTQ->DTQ_FILATU <> cFilAnt
					lMsgChg := .T.
					lRet    := .F.
				EndIf
			Else
				If lF11RotRot .And. F11RotRote(DTQ->DTQ_ROTA)  //Podera ser alterado uma viagem em transito, incluindo uma Rota por Roteiro
					lRet:= .T.
				ElseIf lPrcMerNpr //-- Processo de retirada de mercadoria não prevista
					lRet:= .T.
				Else
					lRet := .F.
				EndIf
			EndIf

			If !lRet .And. lHelp
				If lMsgChg
					Help(' ', 1, 'TMSXFUNA16') //-- Viagem nao esta Disponivel para esta Filial
				Else
					Help(' ', 1, 'TMSXFUNA03') //-- Viagem nao esta em Aberto
				EndIf
			EndIf

			If !lRet .And. lMsgErr
			    cSerTMS := DTQ->DTQ_SERTMS
			    cTipTra := DTQ->DTQ_TIPTRA
			    If lMsgChg
					AAdd( aMsgErr, { STR0017 + cViagem + STR0023 , '02', "TMSA140()" } ) //"Viagem "###" não está Disponível para esta Filial."
				Else
					AAdd( aMsgErr, { STR0017 + cViagem + STR0024 , '02', "TMSA140()" } ) //"Viagem "###" não está em Aberto."
				EndIf
			EndIf

		ElseIf DTQ->DTQ_STATUS != StrZero(1,Len(DTQ->DTQ_STATUS)) .And. DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS))
			//-- Permitir incluir ordens de coletas em viagens em transito
			If DTQ->DTQ_STATUS != StrZero(2,Len(DTQ->DTQ_STATUS)) //-- Em Transito
				If lRet
					If !lF11RotRot .Or. (lF11RotRot .And. !F11RotRote(DTQ->DTQ_ROTA))  //Podera ser alterado uma viagem em transito, incluindo uma Rota por Roteiro
						If	lHelp
							Help(' ', 1, 'TMSXFUNA03') //-- Viagem nao esta em Aberto
						EndIf
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	//-- Verifica se a viagem esta em transito
	If lRet .And. lTransito
		If  DTQ->DTQ_STATUS != StrZero(2,Len(DTQ->DTQ_STATUS))
			If lHelp
				Help(' ', 1, 'TMSXFUNA25')	//-- Viagem nao esta em transito
			EndIf
			If lMsgErr
				AAdd( aMsgErr, { STR0017 + cViagem + STR0025, '03', 'TMSA140()' } ) //"Viagem "###" nao esta em Transito."
			EndIf
			lRet := .F.
		EndIf
	EndIf
	//-- Verifica se ha manifesto
	DTX->(DbSetOrder(3))
	If	lRet .And. lManifesto .And. DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. ! DTX->(MsSeek(xFilial('DTX') + cFilOri + cViagem)) .And.;
		DTQ->DTQ_TIPVIA <> StrZero( 2, Len(DTQ->DTQ_TIPVIA) )
		If lHelp
			Help(' ', 1, 'TMSXFUNA05')	//-- Manifesto nao Encontrado para a Viagem
		EndIf
		If lMsgErr
			AAdd( aMsgErr, { STR0026 + cViagem  , '05', 'TMSA190()' } ) //"Nao foi Gerado Manifesto para a Viagem "
		EndIf
		lRet := .F.
	EndIf
	//-- Verifica se ha contrato de carreteiro
	DTY->( DbSetOrder( 2 ) )
	If	lRet .And. lContrato .And. DTY->(MsSeek(xFilial('DTY') + cFilOri + cViagem)) .And.;
		DTY->DTY_FILORI == cFilAnt
		If lHelp
			Help(' ', 1, 'TMSXFUNA06')	//-- Manutencoes nao sao permitidas em viagens que ja tenham contrato de carreteiro
		EndIf
		If lMsgErr
			AAdd( aMsgErr, { STR0027 + cViagem  , '06', 'TMSA250()' } ) //"Ja foi gerado Contrato de Carreteiro para a Viagem "
		EndIf
		lRet := .F.
	EndIf

	//-- Verifica se ha complemento e Se Cód. Do Veículo Está Informado
	DTR->(DbSetOrder(1))
	If	lRet .And.;
		lComplem .And.;
		( DTR->( ! MsSeek(xFilial('DTR') + cFilOri + cViagem)) .Or. (DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem)) .And. Empty(DTR->DTR_CODVEI )))
		If lHelp
			Help( ' ', 1, 'TMSXFUNA24' ) //-- Complemento de viagem nao encontrado (DTR)
		EndIf
		If lMsgErr
			AAdd( aMsgErr, { STR0028 + cViagem  , '07', 'TMSA240()' } ) //'Complemento de viagem nao encontrado (DTR). Viagem No. '
		EndIf
		lRet := .F.
	EndIf

	If	lRet .And. lVazia .And. DTQ->DTQ_TIPVIA == StrZero(2,Len(DTQ->DTQ_TIPVIA))
		If	lHelp
			Help( ' ', 1, 'TMSXFUNA14' ) //-- Viagem Vazia
		EndIf
		If lMsgErr
			AAdd( aMsgErr, { STR0017 + cViagem + STR0029 , '08', 'TMSA140()' } ) //"Viagem "###" esta Vazia."
		EndIf
		lRet := .F.
	EndIf
	//-- Verifica se a viagem esta bloqueada
	DUC->(DbSetOrder(2))
	If	lRet .And. lBloqueio .And. DUC->(MsSeek(xFilial('DUC') + StrZero(1,Len(DUC->DUC_STATUS)) + cFilOri + cViagem))
		If	lHelp
			Help( ' ', 1, 'TMSXFUNA15' ) //-- Viagem Bloqueada. (DUC)
		EndIf
		If lMsgErr
			AAdd( aMsgErr, { STR0017 + cViagem + STR0030 , '09', 'TMSA140()' } ) //"Viagem "###" Bloqueada."
		EndIf
		lRet := .F.
	EndIf

	If	lRet .And. lFechada .And. ! TMSDTQStatus(5)
		If	lHelp
			Help( ' ', 1, 'TMSXFUNA19' ) //-- Viagem nao esta fechada
		EndIf
		If lMsgErr
			AAdd( aMsgErr, { STR0017 + cViagem + STR0031 , '11', 'TMSA140()' } ) //"Viagem "###" nao esta fechada."
		EndIf
		lRet := .F.
	EndIf
	//-- Verifica se ha operacoes encerradas para a viagem
	DTW->(DbSetOrder(3))
	If	lRet .And. lOperacao .And. DTW->(MsSeek(xFilial('DTW') + cFilOri + cViagem + StrZero(2,Len(DTW->DTW_STATUS))))
		If	lHelp
			Help('',1,'TMSXFUNA33')		//-- Ha operacoes encerradas para a viagem
		EndIf
		If	lMsgErr
			AAdd( aMsgErr, { STR0032 + cViagem  , '11', 'TMSA140()' } ) //"Ha operacoes encerradas para a viagem "
		EndIf
	EndIf
	/* Verifica se a viagem é planejada e está vinculada a uma programação de carga. */
	If lCompVazio .And. DTQ->DTQ_TIPVIA == '3' .And. !Empty(Posicione('DF8',2,xFilial('DF8')+cFilOri+cViagem,'DF8_NUMPRG'))
		If	lHelp
			Help(' ', 1, 'TMSXFUNA43')
		EndIf
		If	lMsgErr
			AAdd( aMsgErr, { STR0217 + cViagem  , '11', 'TMSA140()' } ) //"Exite Programação de Carregamento vinculada a viagem "
		EndIf
		lRet := .F.
	EndIf
ElseIf cTipOco == StrZero( 9, Len(DT2->DT2_TIPOCO) ) .And. lRet .And. Empty(cViagem)	// Gera Indenizacao
	lRet := .T.
Else
	If lHelp
		Help(' ', 1, 'TMSXFUNA07') 	//-- Viagem nao encontrada (DTQ).
	EndIf
	If lMsgErr
		AAdd( aMsgErr, { STR0017 + cViagem + STR0033 , '10', 'TMSA140()' } ) //"Viagem "###" nao encontrado (DTQ)."
	EndIf
	lRet := .F.
EndIf

RestArea(aAreaDTY)
RestArea(aAreaDTX)
RestArea(aAreaDTR)
RestArea(aAreaDUC)
RestArea(aAreaDTW)
RestArea(aAreaAnt)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSPedido ³ Autor ³ Alex Egydio           ³ Data ³14.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera pedido de venda a partir do SIGATMS.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSPedido(ExpA1,ExpA2,ExpN1,ExpB1,ExpB2)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Cabecalho do pedido de venda                       ³±±
±±³          ³ ExpA2 = Itens do pedido de venda                           ³±±
±±³          ³ ExpN1 = Opcao de manutencao 3=Incluir, 5=Excluir           ³±±
±±³          ³ ExpB1 = Funcao executada a cada item do pedido de venda    ³±±
±±³          ³ ExpB2 = Funcao executada apos gerar o pedido de venda      ³±±
±±³          ³ ExpL1 = Indica se executa ou nao o ponto de entrada        ³±±
±±³          ³         TMAPEDSC6 devido ao fechamento de viagem ter que   ³±±
±±³          ³         gerar o pedido para baixar o estoque do produto    ³±±
±±³          ³         que efetuou a entrada no estoque                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSPedido( aCab, aItens, nOpcx, bBloc1, bBloc2, lExcPedSC6 )

Local aAreaAnt     := GetArea()
Local aAreaSC5     := SC5->( GetArea() )
Local aAreaSC6     := SC6->( GetArea() )
Local cPedido      := ''
Local cSeek        := ''
//-- Variaveis p/uso das funcoes maavalsc5 e maavalsc6
Local lLiberOk     := .T.
Local lResidOk     := .T.
Local lFaturOk     := .F.
Local nCampos      := 0
Local nCntFor      := 0
Local n1Cnt        := 0
Local cMay         := 0

DEFAULT aCab	    := {}
DEFAULT aItens	    := {}
DEFAULT nOpcx	    := 3
DEFAULT bBloc1	    := {|ExpA1,ExpC1,ExpL1,ExpN1| .T. }
DEFAULT bBloc2   	 := {|ExpC1| .T. }
DEFAULT lExcPedSC6 := .T.

If	nOpcx	== 3							//-- Incluir

	For nCntFor := 1 To Len( aItens )
		//-- Gera cabecalho do pedido de venda.

		Begin Transaction
		If	nCntFor == 1
			cPedido := CriaVar("C5_NUM",.T.)

			// Ajusta SXE e SXF caso estejam corrompidos.
			cMay := "SC5"+AllTrim(xFilial('SC5'))+cPedido
			FreeUsedCode()
			SC5->(DbSetOrder(1))
			While SC5->(MsSeek(xFilial('SC5')+cPedido)) .Or. !MayIUseCode(cMay)
				ConfirmSx8()
				cPedido := CriaVar("C5_NUM",.T.)
				FreeUsedCode()
				cMay := "SC5"+AllTrim(xFilial('SC5'))+cPedido
			EndDo

			//-- Atualiza o cabecalho do pedido de venda.
			RecLock('SC5',.T.)
			For n1Cnt := 1 TO Len(aCab)
				SC5->(FieldPut( FieldPos(aCab[ n1Cnt, 1 ]), aCab[ n1Cnt, 2 ]))
			Next n1Cnt
			SC5->C5_FILIAL := xFilial( 'SC5' )
			SC5->C5_NUM := cPedido

			//-- Atualiza os acumulados do SC5.
			MaAvalSC5('SC5',1,.F.,.F.,@lLiberOk,@lResidOk,@lFaturOk)

			If ( __lSx8 )
				ConfirmSx8()
			EndIf
		EndIf

		If	! Empty( cPedido )

			RecLock('SC6',.T.)
			nCampos := Len(aItens[nCntFor])
			For n1Cnt := 1 To nCampos
				SC6->( FieldPut(FieldPos(aItens[nCntFor][n1Cnt][1]),aItens[nCntFor][n1Cnt][2]) )
			Next

			If lPedSC6 .And. lExcPedSC6
			   SC6->C6_PRODUTO := ExecBlock("TMAPEDSC6",.F.,.F.,{SC6->C6_PRODUTO})
			EndIf
			SC6->C6_FILIAL := xFilial( 'SC6' )

			MaAvalSC6('SC6',1,'SC5',.F.,.F.,@lLiberOk,@lResidOk,@lFaturOk)

			Eval( bBloc1, cPedido, lLiberOk, nCntFor )

		EndIf

		If lGrvPed
			ExecBlock("TMAGRVPED",.F.,.F.)
		EndIf


		End Transaction
	Next

	If	! Empty( cPedido )
		Eval( bBloc2, cPedido )
	EndIf

ElseIf	nOpcx == 5									//-- Excluir
	Begin Transaction
	//-- Na exclusao o vetor acab deve vir com o nome do campo C5_NUM e seu conteudo especificado.

	nCampos	:= Ascan( aCab, { |x| AllTrim( x[1] ) == 'C5_NUM' } )
	cPedido	:= aCab[ nCampos, 2 ]

	SC5->( DbSetOrder(1) )
	SC6->( DbSetOrder(1) )

	If	! Empty( cPedido ) .And. SC5->( DbSeek( xFilial('SC5') + cPedido, .F. ) )
		If	SC6->( DbSeek( cSeek := xFilial('SC6') + SC5->C5_NUM, .F. ) )
			While SC6->( DbSeek( cSeek, .F.) )

				//-- Efetua o estorno dos itens do pedido de venda.
				RecLock('SC6',.F.)
				MaAvalSC6('SC6',2,'SC5',.F.,.F.,@lLiberOk,@lResidOk,@lFaturOk)

				DbSelectArea('SC6')
				SC6->( DbDelete() )
				MsUnLock()

			EndDo
			//-- Efetua o estorno do cabecalho do pedido de venda.
			MaAvalSC5('SC5',2,.F.,.F.,@lLiberOk,@lResidOk,@lFaturOk)

		  	DbSelectArea('SC5')
		   SC5->( DbDelete() )
		   MsUnLock()
		EndIf
	EndIf

	End Transaction
EndIf

RestArea( aAreaSC6 )
RestArea( aAreaSC5 )
RestArea( aAreaAnt )

Return( NIL )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSExecDCF³ Autor ³ Alex Egydio           ³ Data ³14.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de execucao automatica dos servicos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSExecDCF()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do servico                                  ³±±
±±³          ³ ExpC2 = Codigo do produto                                  ³±±
±±³          ³ ExpC3 = Documento                                          ³±±
±±³          ³ ExpC4 = Serie                                              ³±±
±±³          ³ ExpC5 = Codigo do cliente                                  ³±±
±±³          ³ ExpC6 = Loja do cliente                                    ³±±
±±³          ³ ExpL1 = Cria Operacoes de Transporte                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSExecDCF( cServic, cCodPro, cDocto, cSerie, cCliente, cLoja )

Local aAreaAnt	:= GetArea()
Local aAreaDC5	:= DC5->( GetArea() )
Local aAreaDC5a:= {}
Local aAreaDCF	:= DCF->( GetArea() )
Local cSeek		:= ''
Local cFunExe	:= ''
Local nRegDCF	:= 0

//-- Posiciona no arq. de execucao de servicos.
DCF->( DbSetOrder( 3 ) )
If	DCF->( MsSeek( xFilial('DCF') + cServic + cCodPro + cDocto + cSerie + cCliente + cLoja, .F. ) )

	nRegDCF  := DCF->( Recno() )

	DbSelectArea('DC5')
	DbSetOrder( 1 )
	If	DC5->( MsSeek( cSeek := xFilial('DC5') + DCF->DCF_SERVIC, .F.) )
		While DC5->( !Eof() .And. DC5->DC5_FILIAL + DC5->DC5_SERVIC == cSeek )

			//-- Seta o Status do Servico para "Interrompido".
			DLA150Stat('2')

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa as Tarefas (SX5 - Tab L6) Referentes ao Servico  (DC5)  ou    ³
			//³ Executa as Atividades referentes a Tarefa (DC6)                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( cFunExe := AllTrim( Tabela( 'L6', DC5->DC5_FUNEXE, .F.) ) )
				cFunExe		+= If(!('('$cFunExe),'()','')
				aAreaDC5a	:= DC5->( GetArea() )
				If	TMSAvalFun( StrTran( cFunExe, '"', "'") )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza Status do Servico para "Executado"                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DCF->(dbGoto(nRegDCF))
					DLA150Stat('3')
				EndIf
				RestArea(aAreaDC5a)
			EndIf
			DbSelectArea('DC5')
			DbSkip()
		EndDo
	EndIf
EndIf

RestArea( aAreaDCF )
RestArea( aAreaDC5 )
RestArea( aAreaAnt )

Return( NIL )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSCriaDTW³ Autor ³ Alex Egydio           ³ Data ³21.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Operacoes de Transporte                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSCriaDTW()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor para gravacao de dados. No padrao MsExecAuto ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSCriaDTW( aCab )
Local lRet     := .T.
Local n1Cnt    := 0
Local nPos     := 0
Local aArea    := GetArea()
Local aAreaDTW := DTW->(GetArea())

RecLock('DTW', .T.)
For n1Cnt := 1 To DTW->( FCount() )
	nPos := AScan( aCab, {|x| Alltrim(x[1]) == AllTrim(DTW->(FieldName(n1Cnt)))} )
	&("DTW->" + AllTrim(DTW->(FieldName(n1Cnt)))) := If( nPos > 0, aCab[nPos, 2], CriaVar(DTW->(FieldName(n1Cnt)),.T.) )
Next
DTW->DTW_FILIAL := xFilial('DTW')
DTW->(MsUnLock())

RestArea(aAreaDTW)
RestArea(aArea)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSContrat³ Autor ³ Patricia A. Salomao   ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica o Contrato do Cliente                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSContrat(ExpC1,ExpC2,ExpD1,ExpC3,ExpL1,ExpC4,ExpL2,ExpC5, ³±±
±±³          ³           ExpC6,ExpC7,ExpC8,ExpC9,ExpC10,ExpC11,ExpC12)    ³±±
±±³          ³           ExpC13,ExpC14,ExpC15,ExpC16,ExpC17) 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Cliente                                   ³±±
±±³          ³ExpC2 - Loja do Cliente                                     ³±±
±±³          ³ExpD1 - DataBase                                            ³±±
±±³          ³ExpC3 - Servico                                             ³±±
±±³          ³ExpL1 - Valida se mostra Help, caso nao encontre o Contrato.³±±
±±³          ³ExpC4 - Tipo de Frete (CIF / FOB)                           ³±±
±±³          ³ExpL2 - .T. = Verifica contrato do cliente generico         ³±±
±±³          ³ExpC5 - 1 = Considera a vigencia atual do contrato          ³±±
±±³          ³        2 = Considera a proxima vigencia do contrato        ³±±
±±³          ³ExpC6 - Cliente Remetente                                   ³±±
±±³          ³ExpC7 - Loja do Remetente                                   ³±±
±±³          ³ExpC8 - Cliente Destinatario                                ³±±
±±³          ³ExpC9 - Loja do Destinatario                                ³±±
±±³          ³ExpC10- Tipo de Transporte                                  ³±±
±±³          ³ExpC11- Cliente Devedor                                     ³±±
±±³          ³ExpC12- Loja Devedor                                        ³±±
±±³          ³ExpC13- Tipo Nota Fiscal                                    ³±±
±±³          ³ExpC14- Vigencia da Tab. Fret                               ³±±
±±³          ³ExpC15- Cliente de Calculo                                  ³±±
±±³          ³ExpC16- Loja de Calculo                                     ³±±
±±³          ³ExpC17- Codigo da Negociação                                ³±±
±±³          ³ExpC18- Nro Contrato do Docto de Reentrega                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo dados do Contrato                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSContrat( cCliente, cLoja, dData, cServic, lHelp, cTipFre, lChkCliGen,;
                     cVigCon, cCliRem, cLojRem, cCliDes, cLojDes, cTipTra, cCliDev,;
                     cLojDev, cTipoNF, lVigTabFre, cCliCal, cLojCal,lTMSA491, lDocCompl, cCodNeg, cContrReen )

Local aPerfil      := {}
Local lAchou       := .F.
Local lCliGen      := .F.
Local cCliGen      := ""
Local cLojGen      := ""
Local aRetorno     := {}
Local cAliasQry    := GetNextAlias()
Local cQuery       := ""
Local cAgrNfc      := "1" //-- Agrupa NF ? Sim
Local cPesCtr      := 0   //-- Peso Max. por CTRC
Local cNFCtr       := 1   //-- Qtde. de Nfs por CTRC
Local cAjuObr      := "2" //-- Ajuste Obrigatorio ?  Nao
Local cTaxCtr      := "1" //-- Taxa por CTRC ? Sim
Local aRet         := {}
Local cTabFre      := ""
Local cTipTab      := ""
Local cPrcProd     := ""
Local aAreaAAM     := AAM->(GetArea())
Local lRet         := .T.
Local nCount       := 0
Local nTamArray    := 0
Local cAliasInt    := ''
Local lTMSINTER    := ( Left(FunName(),7) == "TMSAI70" )      //Rodoviario Internacional
Local cFixVar      := ""
Local aCliPe       := {}  // retorno do ponto de entrada TMALTCLI
Local cCliOri      := ""
Local cLojOri      := ""
Local lCliOri      := .T.
Local lFOBDIR      := .F.
Local cCtrVenc     := ""
Local aDadosDDA    := {}
Local aDadosDDC    := {}
Local aDadosDDP    := {}
Local nAdiDoc      := 0
Local cProRateio   := ""
Local cCriRateio   := ""
Local cBacRateio   := ""
Local cCrDvFa      := ""
Local cCrDvDc      := ""
Local cValCol      := ""
Local cCrDvHv      := ""
Local lCmpRatNew   := DUX->(ColumnPos("DUX_CRDVFA")) > 0 .And. DUX->(ColUmnPos('DUX_CRDVHV')) > 0
Local cEstAgr      := "1"
Local lCpoSerie    := DDA->(FieldPos('DDA_SERIE')) > 0

Default cCliente   := ''
Default cLoja      := ''
Default dData      := dDataBase
Default cServic    := ''
Default lHelp      := .T.
Default cTipFre    := '3'
Default lChkCliGen := .T.
Default cVigCon    := '1'
Default cTipTra    := ''
Default cCliDev    := ''
Default cLojDev    := ''
Default cTipoNF    := ''
Default lVigTabFre := .T.
Default cCliCal    := ''
Default cLojCal    := ''
Default lTMSA491   := .F.
Default lDocCompl  := .F.
Default cCodNeg    := '' //Variavel que indica o Codigo da Negociação do cliente conforme o novo conceito de negociação.
Default cContrReen := ''


If cTipFre == '3'

	If Empty(cTipTra)
		cTipTra	:= IIf( Type( "M->DTC_TIPTRA" )=='U', '', M->DTC_TIPTRA)
	EndIf

	If lTMSINTER .And. Empty(cTipTra)
		cTipTra:= StrZero(4,Len(DT5->DT5_TIPTRA))
	EndIf

	If cTipTra == StrZero(4,Len(DT5->DT5_TIPTRA))   //-- Rodoviario Internacional
		If M->DIK_TIPFRE == '3' //-- CIF/FOB
			If M->DIK_DEVFRE == '2' //-- Destinatario
				cTipFre := '2' //-- FOB
			Else
				cTipFre := '1' //-- CIF
			EndIf
		Else
			cTipFre := M->DIK_TIPFRE
		EndIf
	EndIf
EndIf

//-- Cliente/loja original para validar se hove alteracao.
cCliOri := cCliente
cLojOri := cLoja

If lTMALTCLI
	aCliPe := ExecBlock("TMALTCLI",.F.,.F.,{cCliente,cLoja,cServic,cTipFre,cCodNeg})
	If ValType(aCliPe) == "A" .and. Len(aCliPe) == 2
		cCliente := aCliPe[1]
		cLoja    := aCliPe[2]
	Endif
Endif

//--VERIFICA SE OS CONTRATOS PARA O CLIENTE
//--ESTAO DENTRO DA VIGENCIA. CASO CONTRARIO
//--ATUALIZA O STATUS DO CONTRATO PARA "SUSPENSO" (2)
If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
EndIf

aRetorno := {}
aRetorno := GetContrat( cCliente, cLoja, dData, cServic, cTipFre, cVigCon, cTipTra, cCodNeg)

If Len(aRetorno) == 0
	//--VERIFICA SE OS CONTRATOS PARA O CLIENTE
	//--ESTAO DENTRO DA VIGENCIA. CASO CONTRARIO
	//--ATUALIZA O STATUS DO CONTRATO PARA "SUSPENSO" (2)
	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf

	cAliasQry   := GetNextAlias()
	cQuery := ""
	cQuery := " SELECT R_E_C_N_O_ NRECNO "
	cQuery += " FROM " + RetSQLTab('AAM')
	cQuery += " WHERE AAM.AAM_FILIAL = '" + xFilial("AAM") + "' "
	cQuery += " AND AAM.AAM_CODCLI = '" + cCliente + "' "
	cQuery += " AND AAM.AAM_LOJA   = '" + cLoja + "' "
	cQuery += " AND AAM.AAM_ABRANG = '1' "
	cQuery += " AND AAM.AAM_STATUS = '1' "
	cQuery += " AND ( AAM.AAM_TIPFRE = '3' OR AAM.AAM_TIPFRE = '" + cTipFre + "') "
	cQuery += " AND AAM.AAM_FIMVIG <> ' ' AND AAM.AAM_FIMVIG < '" + DtoS(Date())+ "'"
	cQuery += " AND AAM.D_E_L_E_T_ = ' ' "
	//cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T. )
	While (cAliasQry)->(!Eof())
		AAM->(dbGoTo( (cAliasQry)->NRECNO ))
		Reclock('AAM',.F.)
		AAM->AAM_STATUS := StrZero(2, Len(AAM->AAM_STATUS))
		AAM->(MsUnlock())
		If Empty(cCtrVenc)
			cCtrVenc := "'"
		Else
			cCtrVenc += ",'"
		EndIf
		cCtrVenc += AAM->AAM_CONTRT + "'"
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(DbCloseArea())

	//--VERIFICA SE O ITEM DO CONTRATO PARA O CLIENTE
	//--ESTA DENTRO DA VIGENCIA. CASO CONTRARIO
	//--ATUALIZA O STATUS DO ITEM DO CONTRATO PARA "SUSPENSO" (2)
	If !Empty(cCtrVenc)
		If Select(cAliasQry) > 0
			(cAliasQry)->(DbCloseArea())
		EndIf

		cAliasQry   := GetNextAlias()
		cQuery := " SELECT R_E_C_N_O_ NRECNO "
		cQuery += " FROM " + RetSQLTab('DDC')
		cQuery += " WHERE DDC.DDC_FILIAL = '" + xFilial("DDC") + "' "
		cQuery += "   AND DDC.DDC_NCONTR IN (" + cCtrVenc + ")
		cQuery += "   AND DDC.DDC_STATUS = '1' "
		cQuery += "   AND DDC.DDC_FIMVIG <> ' ' AND DDC.DDC_FIMVIG < '" + DtoS(Date())+ "'"
		cQuery += "   AND DDC.D_E_L_E_T_ = ' ' "
		//cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T. )
		While (cAliasQry)->(!Eof())
			DDC->(dbGoTo( (cAliasQry)->NRECNO ))
			Reclock('DDC',.F.)
			DDC->DDC_STATUS := StrZero(2, Len(DDC->DDC_STATUS))
			DDC->(MsUnlock())
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(DbCloseArea())
	EndIf

   	If !Empty(cContrReen)  //Reentrega utiliza o mesmo contrato do documento original.
		If Select(cAliasQry) > 0
			(cAliasQry)->(DbCloseArea())
		EndIf
		cAliasQry   := GetNextAlias()

		cQuery := " SELECT "
		cQuery += " AAM.R_E_C_N_O_ RECAAM, AAM.AAM_CONTRT, AAM.AAM_CPAGPV, AAM.AAM_SELSER "
		cQuery += ", AAM.AAM_CODCLI, AAM.AAM_LOJA, AAM.AAM_TIPFRE "
		cQuery += ", AAM.AAM_AGRNFC, AAM.AAM_TAXCTR, AAM.AAM_PESCTR, AAM.AAM_NFCTR, AAM.AAM_AJUOBR  "
		cQuery += ", AAM.AAM_PRCPRD "
		If (AAM->(ColumnPos('AAM_ESTAGR')) > 0)
			cQuery += ", AAM.AAM_ESTAGR "
		EndIf

		cQuery += ", DDA.DDA_FATCUB, DDA.DDA_TABFRE, DDA.DDA_TIPTAB, DDA.DDA_TABALT, DDA.DDA_TIPALT "
		cQuery += ", DDA.DDA_ITEM  , DDA.DDA_CODNEG, DDA.DDA_SERVIC, DDA.DDA_FATCUB, DDA.DDA_TABFRE, DDA.DDA_TIPTAB, DDA.DDA_TABALT, DDA.DDA_TIPALT "
		cQuery += ", DDA.DDA_PESO  , DDA.DDA_PESOM3, DDA.DDA_QTDVOL, DDA.DDA_VALMER, DDA.DDA_VALFIX, DDA.DDA_FIXVAR, DDA.DDA_PORTMS, DDA.DDA_EDITMS "
		cQuery += ", DDA.DDA_DIACOL, DDA.DDA_AGEVIR, DDA.DDA_SRVCOL, DDA.DDA_TIPOPE "
		cQuery += ", DDA.DDA_ADIDOC, DDA.DDA_PRORAT, DDA.DDA_CRIRAT, DDA.DDA_BACRAT, DDA.DDA_CRDVFA, DDA.DDA_CRDVDC, DDA.DDA_VALCOL, DDA.DDA_CRDVHV "
		
		If lCpoSerie
			cQuery += ", DDA.DDA_SERIE "
		EndIf	
		
		cQuery += ", DDC.DDC_ITEM  , DDC.DDC_CODNEG, DDC.DDC_TPCONT, DDC.DDC_INIVIG, DDC.DDC_FIMVIG, DDC.DDC_STATUS, DDC.DDC_AGEVIR, DDC.DDC_SRVCOL, DDC.DDC_TIPOPE "
		cQuery += ", DDC.DDC_ADIDOC, DDC.DDC_PRORAT, DDC.DDC_CRIRAT, DDC.DDC_BACRAT, DDC.DDC_VALCOL, DDC.DDC_CRDVHV "

		If lCpoSerie
			cQuery += ", DDC.DDC_SERIE "
		EndIf	

		cQuery += "    FROM "
		cQuery += RetSqlName("AAM") + " AAM, "
		cQuery += RetSqlName("DDA") + " DDA, "
		If Empty(cCodNeg)
			cQuery += RetSqlName("DDB") + " DDB,"
		EndIf
		cQuery += RetSqlName("DDC") + " DDC "
		cQuery += "    WHERE AAM.AAM_FILIAL = '" + xFilial("AAM") + "' "
		cQuery += "      AND AAM.AAM_CONTRT = '" + cContrReen + "' "
		cQuery += "      AND ( AAM.AAM_TIPFRE = '3' "
		cQuery += "       OR   AAM.AAM_TIPFRE = '" + cTipFre + "' ) "
		cQuery += "      AND AAM.D_E_L_E_T_ = ' ' "
		cQuery += "      AND DDA.DDA_FILIAL = '" + xFilial("DDA") + "' "
		cQuery += "      AND DDA.DDA_NCONTR = AAM.AAM_CONTRT "

		If Empty(cCodNeg)
			cQuery += "      AND DDB.DDB_FILIAL = '" + xFilial("DDB") + "' "
			cQuery += "      AND DDB.DDB_CODNEG = DDA.DDA_CODNEG   "
			cQuery += "      AND DDB.D_E_L_E_T_ = ' ' "
		Else
			cQuery += "      AND DDA.DDA_CODNEG = '" + cCodNeg + "' "
		EndIf

		If !Empty(cServic)
			cQuery += "      AND DDA.DDA_SERVIC = '" + cServic + "' "
		EndIf
		cQuery += "      AND DDA.D_E_L_E_T_ = ' ' "
		cQuery += "      AND DDC.DDC_FILIAL = '" + xFilial("DDC") + "' "
		cQuery += "      AND DDC.DDC_NCONTR = DDA.DDA_NCONTR "
		cQuery += "      AND DDC.DDC_CODNEG = DDA.DDA_CODNEG "
		cQuery += "      AND DDC.D_E_L_E_T_ = ' ' "

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->(!Eof())
			AAM->( dbGoto( (cAliasQry)->RECAAM ) )
			lAchou  := .T.
		EndIf
	EndIf
	//--- Fim Reentrega

	If !lAchou
		If Select(cAliasQry) > 0
	    	(cAliasQry)->(DbCloseArea())
	  	EndIf
		cAliasQry   := GetNextAlias()
		cQuery := " SELECT "
		cQuery += " AAM.R_E_C_N_O_ RECAAM, AAM.AAM_CONTRT, AAM.AAM_CPAGPV, AAM.AAM_SELSER, AAM.AAM_CODCLI, AAM.AAM_LOJA, AAM.AAM_TIPFRE "
		cQuery += ", AAM.AAM_AGRNFC, AAM.AAM_TAXCTR, AAM.AAM_PESCTR, AAM.AAM_NFCTR, AAM.AAM_AJUOBR "
		cQuery += ", AAM.AAM_PRCPRD "
		If (AAM->(ColumnPos('AAM_ESTAGR')) > 0)
			cQuery += ", AAM.AAM_ESTAGR "
		EndIf

		cQuery += ", DDA.DDA_ITEM  , DDA.DDA_CODNEG, DDA.DDA_SERVIC, DDA.DDA_FATCUB, DDA.DDA_TABFRE, DDA.DDA_TIPTAB, DDA.DDA_TABALT, DDA.DDA_TIPALT "
		cQuery += ", DDA.DDA_PESO  , DDA.DDA_PESOM3, DDA.DDA_QTDVOL, DDA.DDA_VALMER, DDA.DDA_VALFIX, DDA.DDA_FIXVAR, DDA.DDA_PORTMS, DDA.DDA_EDITMS "
		cQuery += ", DDA.DDA_DIACOL, DDA.DDA_AGEVIR, DDA.DDA_SRVCOL, DDA.DDA_TIPOPE "

		If lCpoSerie
			cQuery += ", DDA.DDA_SERIE "
		EndIf	

		cQuery += ", DDA.DDA_ADIDOC, DDA.DDA_PRORAT, DDA.DDA_CRIRAT, DDA.DDA_BACRAT, DDA.DDA_CRDVFA, DDA.DDA_CRDVDC, DDA.DDA_VALCOL, DDA.DDA_CRDVHV "
		cQuery += ", DDC.DDC_ITEM  , DDC.DDC_CODNEG, DDC.DDC_TPCONT, DDC.DDC_INIVIG, DDC.DDC_FIMVIG, DDC.DDC_STATUS, DDC.DDC_AGEVIR, DDC.DDC_SRVCOL, DDC.DDC_TIPOPE "
		cQuery += ", DDC.DDC_ADIDOC, DDC.DDC_PRORAT, DDC.DDC_CRIRAT, DDC.DDC_BACRAT, DDC.DDC_VALCOL, DDC.DDC_CRDVHV "

		If lCpoSerie
			cQuery += ", DDC.DDC_SERIE "
		EndIf

		cQuery += ", DDA.DDA_FIXVAR "
		cQuery += "    FROM "
		cQuery += RetSqlName("AAM") + " AAM, "
		cQuery += RetSqlName("DDA") + " DDA, "
		If Empty(cCodNeg)
			cQuery += RetSqlName("DDB") + " DDB,"
		EndIf
		cQuery += RetSqlName("DDC") + " DDC "
		cQuery += "    WHERE AAM.AAM_FILIAL = '" + xFilial("AAM") + "' "
		cQuery += "      AND AAM.AAM_CODCLI = '" + cCliente + "' "
		cQuery += "      AND AAM.AAM_LOJA   = '" + cLoja + "' "
		cQuery += "      AND AAM.AAM_ABRANG = '1' "
		cQuery += " AND AAM.AAM_CONTRT <> ' ' "
		//-- Considera a vigencia atual do contrato
		If	cVigCon == '1'
			cQuery += "      AND ( AAM.AAM_TIPFRE = '3' "
			cQuery += "       OR   AAM.AAM_TIPFRE = '" + cTipFre + "' ) "

			If !lTMSA491 .And. !lDocCompl
				//--Padrao: Obtem os contratos ATIVOS e vigentes na data
				cQuery += "      AND AAM.AAM_STATUS = '1' "
				cQuery += "      AND AAM.AAM_INIVIG <= '" + DtoS(dData) + "' "
				cQuery += "      AND ( AAM.AAM_FIMVIG = ' ' "
				cQuery += "       OR ( '" + DtoS(dData) + "' BETWEEN AAM.AAM_INIVIG AND AAM.AAM_FIMVIG ) ) "
			Else
				//--Quando a chamada da TMSContrat() eh a partir do programa de Geracao de Faturas (TMSA491),
				//--deve ser verificado o contrato que estava vigente no momento da emissao dos documentos
				//--que irao compor a fatura
				cQuery += "      AND ( (AAM.AAM_STATUS = '1' "
				cQuery += "      AND   AAM.AAM_INIVIG <= '" + DtoS(dData) + "' "
				cQuery += "      AND   ( AAM.AAM_FIMVIG = ' ' "
				cQuery += "       OR   ( '" + DtoS(dData) + "' BETWEEN AAM.AAM_INIVIG AND AAM.AAM_FIMVIG ) ) )"

				//--Este tratamento eh para prever os contratos que jah foram encerrados, porem, foram utilizados
				//--na emissao dos documentos que irao compor a fatura.
				  cQuery += "  OR ( AAM.AAM_STATUS IN ('3','2') AND '"+ DtoS(dData) + "' BETWEEN AAM.AAM_INIVIG AND AAM.AAM_FIMVIG ) "
				  cQuery += "  OR (AAM_STATUS IN ('3','2') AND AAM_FIMVIG = ' '  AND  AAM_INIVIG <= '"+ DtoS(dData) + "'  ) ) "
			EndIf

			//-- Considera a proxima vigencia do contrato
		ElseIf cVigCon == '2'
			cQuery += "      AND ( AAM.AAM_TIPFRE = '3' "
			cQuery += "       OR   AAM.AAM_TIPFRE = '" + cTipFre + "' ) "

			If Empty(dData)
				cQuery += "      AND AAM.AAM_INIVIG > '" + DtoS(dDataBase) + "' "
			Else
				cQuery += "      AND AAM.AAM_INIVIG > '" + DtoS(dData) + "' "
			EndIf
		EndIf
		cQuery += "      AND AAM.D_E_L_E_T_ = ' ' "
		cQuery += "      AND DDA.DDA_FILIAL = '" + xFilial("DDA") + "' "
		cQuery += "      AND DDA.DDA_NCONTR = AAM.AAM_CONTRT "

		If Empty(cCodNeg)
			cQuery += "      AND DDB.DDB_FILIAL = '" + xFilial("DDB") + "' "
			cQuery += "      AND DDB.DDB_CODNEG = DDA.DDA_CODNEG   "
			cQuery += "      AND DDB.D_E_L_E_T_ = ' ' "
		Else
			cQuery += "      AND DDA.DDA_CODNEG = '" + cCodNeg + "' "
		EndIf

		If !Empty(cServic)
			cQuery += "      AND DDA.DDA_SERVIC = '" + cServic + "' "
		EndIf
		cQuery += "      AND DDA.D_E_L_E_T_ = ' ' "
		cQuery += "      AND DDC.DDC_FILIAL = '" + xFilial("DDC") + "' "
		cQuery += "      AND DDC.DDC_NCONTR = DDA.DDA_NCONTR "
		cQuery += "      AND DDC.DDC_CODNEG = DDA.DDA_CODNEG "
		cQuery += "      AND DDC.DDC_STATUS = '1' "
		If cVigCon == '1'
			cQuery += "      AND DDC.DDC_INIVIG <= '" + DtoS(dData) + "' "
			cQuery += "      AND ( DDC.DDC_FIMVIG = ' ' "
			cQuery += "      OR ( '" + DtoS(dData) + "' BETWEEN DDC.DDC_INIVIG AND DDC.DDC_FIMVIG ) ) "
		Else
			cQuery += "      AND DDC.DDC_INIVIG > '" + DtoS(dData) + "' "
		EndIf
		cQuery += "      AND DDC.D_E_L_E_T_ = ' ' "

		cQuery += " UNION ALL "

		cQuery += " SELECT "
		cQuery += " AAM.R_E_C_N_O_ RECAAM, AAM.AAM_CONTRT, AAM.AAM_CPAGPV, AAM.AAM_SELSER, AAM.AAM_CODCLI, AAM.AAM_LOJA, AAM.AAM_TIPFRE "
		cQuery += ", AAM.AAM_AGRNFC, AAM.AAM_TAXCTR, AAM.AAM_PESCTR, AAM.AAM_NFCTR, AAM.AAM_AJUOBR "
		cQuery += ", AAM.AAM_PRCPRD "
		If (AAM->(ColumnPos('AAM_ESTAGR')) > 0)
			cQuery += ", AAM.AAM_ESTAGR "
		EndIf

		cQuery += ", DDA.DDA_ITEM  , DDA.DDA_CODNEG, DDA.DDA_SERVIC, DDA.DDA_FATCUB, DDA.DDA_TABFRE, DDA.DDA_TIPTAB, DDA.DDA_TABALT, DDA.DDA_TIPALT "
		cQuery += ", DDA.DDA_PESO  , DDA.DDA_PESOM3, DDA.DDA_QTDVOL, DDA.DDA_VALMER, DDA.DDA_VALFIX, DDA.DDA_FIXVAR, DDA.DDA_PORTMS, DDA.DDA_EDITMS "
		cQuery += ", DDA.DDA_DIACOL, DDA.DDA_AGEVIR, DDA.DDA_SRVCOL, DDA.DDA_TIPOPE "

		If lCpoSerie
			cQuery += ", DDA.DDA_SERIE "
		EndIf

		cQuery += ", DDA.DDA_ADIDOC, DDA.DDA_PRORAT, DDA.DDA_CRIRAT, DDA.DDA_BACRAT, DDA.DDA_CRDVFA, DDA.DDA_CRDVDC, DDA.DDA_VALCOL, DDA.DDA_CRDVHV "

		cQuery += ", DDC.DDC_ITEM  , DDC.DDC_CODNEG, DDC.DDC_TPCONT, DDC.DDC_INIVIG, DDC.DDC_FIMVIG, DDC.DDC_STATUS, DDC.DDC_AGEVIR, DDC.DDC_SRVCOL, DDC.DDC_TIPOPE  "
		cQuery += ", DDC.DDC_ADIDOC, DDC.DDC_PRORAT, DDC.DDC_CRIRAT, DDC.DDC_BACRAT, DDC.DDC_VALCOL, DDC.DDC_CRDVHV "

		If lCpoSerie
			cQuery += ", DDC.DDC_SERIE "
		EndIf

		cQuery += ", DDA.DDA_FIXVAR "

		cQuery += "    FROM "
		cQuery += RetSqlName("AAM") + " AAM, "
		cQuery += RetSqlName("DDA") + " DDA, "
		If Empty(cCodNeg)
			cQuery += RetSqlName("DDB") + " DDB,"
		EndIf
		cQuery += RetSqlName("DDC") + " DDC "

		cQuery += "    WHERE AAM.AAM_FILIAL = '" + xFilial("AAM") + "' "
		cQuery += "      AND AAM.AAM_CODCLI = '" + cCliente + "' "
		cQuery += "      AND AAM.AAM_ABRANG <> '1' "
		cQuery += " AND AAM.AAM_CONTRT <> ' ' "
		//-- Considera a vigencia atual do contrato
		If	cVigCon == '1'
			cQuery += "      AND ( AAM.AAM_TIPFRE = '3' "
			cQuery += "       OR   AAM.AAM_TIPFRE = '" + cTipFre + "' ) "

			If !lDocCompl
				//--Padrao: Obtem os contratos ATIVOS e vigentes na data
				cQuery += "      AND AAM.AAM_STATUS = '1' "
				cQuery += "      AND AAM.AAM_INIVIG <= '" + DtoS(dData) + "' "
				cQuery += "      AND ( AAM.AAM_FIMVIG = ' ' "
				cQuery += "       OR ( '" + DtoS(dData) + "' BETWEEN AAM.AAM_INIVIG AND AAM.AAM_FIMVIG ) ) "
			Else
				//--Quando a chamada da TMSContrat() eh a partir do programa de Geracao de Faturas (TMSA491),
				//--deve ser verificado o contrato que estava vigente no momento da emissao dos documentos
				//--que irao compor a fatura
				cQuery += "      AND ( (AAM.AAM_STATUS = '1' "
				cQuery += "      AND   AAM.AAM_INIVIG <= '" + DtoS(dData) + "' "
				cQuery += "      AND   ( AAM.AAM_FIMVIG = ' ' "
				cQuery += "       OR   ( '" + DtoS(dData) + "' BETWEEN AAM.AAM_INIVIG AND AAM.AAM_FIMVIG ) ) )"

				//--Este tratamento eh para prever os contratos que jah foram encerrados, porem, foram utilizados
				//--na emissao dos documentos que irao compor a fatura.
				  cQuery += "  OR ( AAM.AAM_STATUS IN ('3','2') AND '"+ DtoS(dData) + "' BETWEEN AAM.AAM_INIVIG AND AAM.AAM_FIMVIG ) "
				  cQuery += "  OR (AAM_STATUS IN ('3','2') AND AAM_FIMVIG = ' '  AND  AAM_INIVIG <= '"+ DtoS(dData) + "'  ) ) "
			EndIf

			//-- Considera a proxima vigencia do contrato
		ElseIf cVigCon == '2'
			cQuery += "      AND ( AAM.AAM_TIPFRE = '3' "
			cQuery += "       OR   AAM.AAM_TIPFRE = '" + cTipFre + "' ) "
			If Empty(dData)
				cQuery += "      AND AAM.AAM_INIVIG > '" + DtoS(dDataBase) + "' "
			Else
				cQuery += "      AND AAM.AAM_INIVIG > '" + DtoS(dData) + "' "
			EndIf
		EndIf
		cQuery += "      AND AAM.D_E_L_E_T_ = ' ' "

		cQuery += "      AND DDA.DDA_FILIAL = '" + xFilial("DDA") + "' "
		cQuery += "      AND DDA.DDA_NCONTR = AAM.AAM_CONTRT "

		If Empty(cCodNeg)
			cQuery += "      AND DDB.DDB_FILIAL = '" + xFilial("DDB") + "' "
			cQuery += "      AND DDB.DDB_CODNEG = DDA.DDA_CODNEG   "
			cQuery += "      AND DDB.D_E_L_E_T_ = ' ' "
		Else
			cQuery += "      AND DDA.DDA_CODNEG = '" + cCodNeg + "' "
		EndIf

		If !Empty(cServic)
			cQuery += "      AND DDA.DDA_SERVIC = '" + cServic + "' "
		EndIf
		cQuery += "      AND DDA.D_E_L_E_T_ = ' ' "
		cQuery += "      AND DDC.DDC_FILIAL = '" + xFilial("DDC") + "' "
		cQuery += "      AND DDC.DDC_NCONTR = DDA.DDA_NCONTR "
		cQuery += "      AND DDC.DDC_CODNEG = DDA.DDA_CODNEG "
		cQuery += "      AND DDC.DDC_STATUS = '1' "
		If cVigCon == '1'
			cQuery += "      AND DDC.DDC_INIVIG <= '" + DtoS(dData) + "' "
			cQuery += "      AND ( DDC.DDC_FIMVIG = ' ' "
			cQuery += "      OR ( '" + DtoS(dData) + "' BETWEEN DDC.DDC_INIVIG AND DDC.DDC_FIMVIG ) ) "
		Else
			cQuery += "      AND DDC.DDC_INIVIG > '" + DtoS(dData) + "' "
		EndIf
		cQuery += "      AND DDC.D_E_L_E_T_ = ' ' "

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->(!Eof())
			AAM->( dbGoto( (cAliasQry)->RECAAM ) )
			lAchou  := .T.
		EndIf
   EndIf

	//-- Se achou o contrato e nao existe o servico especificado como Internacional.
	If lAchou
		If Empty(cTipTra)
			cTipTra	:= IIf( Type( "M->DTC_TIPTRA" )=='U', '' , M->DTC_TIPTRA)
		EndIf

		If cTipTra == StrZero(4,Len(DT5->DT5_TIPTRA)) //-- Rodoviario Internacional

			cAliasInt   := GetNextAlias()
			cQuery := " SELECT AAM_CONTRT "
			cQuery += "    FROM "
			cQuery += RetSqlName("AAM") + " AAM, "
			cQuery += RetSqlName("DDA") + " DDA, "
			If Empty(cCodNeg)
				cQuery += RetSqlName("DDB") + " DDB,"
			EndIf

			cQuery += RetSqlName("DC5") + " DC5  "
			cQuery += "    WHERE AAM.AAM_FILIAL = '" + xFilial("AAM") + "' "
			cQuery += "      AND AAM.AAM_CONTRT = '" + AAM->AAM_CONTRT + "' "
			cQuery += "      AND AAM.D_E_L_E_T_ = ' ' "
			cQuery += "      AND DDA.DDA_FILIAL = '" + xFilial("DDA") + "' "
			cQuery += "      AND DDA.DDA_NCONTR = AAM.AAM_CONTRT "

			If Empty(cCodNeg)
				cQuery += "      AND DDB.DDB_FILIAL = '" + xFilial("DDB") + "' "
				cQuery += "      AND DDB.DDB_CODNEG = DDA.DDA_CODNEG   "
				cQuery += "      AND DDB.D_E_L_E_T_ = ' ' "
			Else
				cQuery += "      AND DDA.DDA_CODNEG = '" + cCodNeg + "' "
			EndIf

			cQuery += "      AND DDA.D_E_L_E_T_ = ' ' "

			cQuery += "      AND DC5.DC5_FILIAL = '" + xFilial("DC5") + "' "
			cQuery += "      AND DC5.DC5_SERVIC = DDA.DDA_SERVIC "
			cQuery += "      AND DC5.DC5_TIPTRA = '4'
			cQuery += "      AND DC5.D_E_L_E_T_ = ' ' "

			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasInt, .F., .T.)
			If (cAliasInt)->(Eof())
				lAchou 		:= .F.
				lChkCliGen	:= .T.
			EndIf
			(cAliasInt)->(DbCloseArea())
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao existir contrato em vigencia para o cliente em questao, verifica   ³
	//³ se existe contrato em vigencia para o Cliente Generico (MV_CLIGEN)        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAchou .And. lChkCliGen
		(cAliasQry)->(DbCloseArea())
		cCliGen      := SuperGetMv("MV_CLIGEN",,"")
		cAliasQry   := GetNextAlias()
		SA1->(DbSetOrder(1))
		If	SA1->(MsSeek(xFilial('SA1')+cCliGen))
			cCliGen := SA1->A1_COD
			cLojGen := SA1->A1_LOJA
		EndIf
		cQuery := " SELECT "
		cQuery += " AAM.R_E_C_N_O_ RECAAM, AAM.AAM_CONTRT, AAM.AAM_CPAGPV, AAM.AAM_SELSER, AAM.AAM_CODCLI, AAM.AAM_LOJA, AAM.AAM_TIPFRE "
		cQuery += ", AAM.AAM_AGRNFC, AAM.AAM_TAXCTR, AAM.AAM_PESCTR, AAM.AAM_NFCTR, AAM.AAM_AJUOBR  "
		cQuery += ", AAM.AAM_PRCPRD "
		If (AAM->(ColumnPos('AAM_ESTAGR')) > 0)
			cQuery += ", AAM.AAM_ESTAGR "
		EndIf

		cQuery += ", DDA.DDA_ITEM  , DDA.DDA_CODNEG, DDA.DDA_SERVIC, DDA.DDA_FATCUB, DDA.DDA_TABFRE, DDA.DDA_TIPTAB, DDA.DDA_TABALT, DDA.DDA_TIPALT "
 		cQuery += ", DDA.DDA_PESO  , DDA.DDA_PESOM3, DDA.DDA_QTDVOL, DDA.DDA_VALMER, DDA.DDA_VALFIX, DDA.DDA_FIXVAR, DDA.DDA_PORTMS, DDA.DDA_EDITMS "
		cQuery += ", DDA.DDA_DIACOL, DDA.DDA_AGEVIR, DDA.DDA_SRVCOL, DDA.DDA_TIPOPE "
		cQuery += ", DDA.DDA_ADIDOC, DDA.DDA_PRORAT, DDA.DDA_CRIRAT, DDA.DDA_BACRAT, DDA.DDA_CRDVFA, DDA.DDA_CRDVDC, DDA.DDA_VALCOL, DDA.DDA_CRDVHV "

		If lCpoSerie
			cQuery += ", DDA.DDA_SERIE "
		EndIf

		cQuery += ", DDC.DDC_ITEM  , DDC.DDC_CODNEG, DDC.DDC_TPCONT, DDC.DDC_INIVIG, DDC.DDC_FIMVIG, DDC.DDC_STATUS, DDC.DDC_AGEVIR, DDC.DDC_SRVCOL, DDC.DDC_TIPOPE  "
		cQuery += ", DDC.DDC_ADIDOC, DDC.DDC_PRORAT, DDC.DDC_CRIRAT, DDC.DDC_BACRAT, DDC.DDC_VALCOL, DDC.DDC_CRDVHV "

		If lCpoSerie
			cQuery += ", DDC.DDC_SERIE "
		EndIf

		cQuery += ", DDA.DDA_FIXVAR "
		cQuery += "    FROM "
		cQuery += RetSqlName("AAM") + " AAM, "
		cQuery += RetSqlName("DDA") + " DDA, "
		If Empty(cCodNeg)
			cQuery += RetSqlName("DDB") + " DDB,"
		EndIf
		cQuery += RetSqlName("DDC") + " DDC "
		cQuery += "    WHERE AAM.AAM_FILIAL = '" + xFilial("AAM") + "' "
		cQuery += "      AND AAM.AAM_CODCLI = '" + cCliGen + "' "
		cQuery += "      AND AAM.AAM_LOJA   = '" + cLojGen + "' "
		cQuery += "      AND AAM.AAM_STATUS = '1' "
		cQuery += " AND AAM.AAM_CONTRT <> ' ' "
		cQuery += "      AND ( AAM.AAM_TIPFRE = '3' "
		cQuery += "       OR   AAM.AAM_TIPFRE = '" + cTipFre + "' ) "
		cQuery += "      AND ( AAM.AAM_FIMVIG = ' ' "
		cQuery += "       OR ( AAM.AAM_INIVIG <= '" + DtoS(dData) + "' AND AAM.AAM_FIMVIG >= '" + DtoS(dData) + "' ) ) "
		cQuery += "      AND AAM.D_E_L_E_T_ = ' ' "
		cQuery += "      AND DDA.DDA_FILIAL = '" + xFilial("DDA") + "' "
		cQuery += "      AND DDA.DDA_NCONTR = AAM.AAM_CONTRT "

		If Empty(cCodNeg)
			cQuery += "      AND DDB.DDB_FILIAL = '" + xFilial("DDB") + "' "
			cQuery += "      AND DDB.DDB_CODNEG = DDA.DDA_CODNEG   "
			cQuery += "      AND DDB.D_E_L_E_T_ = ' ' "
		Else
			cQuery += "      AND DDA.DDA_CODNEG = '" + cCodNeg + "' "
		EndIf

		If !Empty(cServic)
			cQuery += "      AND DDA.DDA_SERVIC = '" + cServic + "' "
		EndIf
		cQuery += "      AND DDA.D_E_L_E_T_ = ' ' "
		cQuery += "      AND DDC.DDC_FILIAL = '" + xFilial("DDC") + "' "
		cQuery += "      AND DDC.DDC_NCONTR = DDA.DDA_NCONTR "
		cQuery += "      AND DDC.DDC_CODNEG = DDA.DDA_CODNEG "
		cQuery += "      AND DDC.DDC_STATUS = '1' "
		cQuery += "      AND DDC.DDC_INIVIG <= '" + DtoS(dData) + "' "
		cQuery += "      AND ( DDC.DDC_FIMVIG = ' ' "
		cQuery += "      OR ( '" + DtoS(dData) + "' BETWEEN DDC.DDC_INIVIG AND DDC.DDC_FIMVIG ) ) "
		cQuery += "      AND DDC.D_E_L_E_T_ = ' ' "

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->(!Eof())
			AAM->( dbGoto( (cAliasQry)->RECAAM ) )
			lAchou  := .T.
			lCliGen := .T.
		EndIf
	EndIf

	If !lAchou
		DUO->(DbSetOrder(1))   // Busca pelo FOBDIR do cliente de calculo
		If	DUO->(MsSeek(xFilial('DUO')+cCliCal+cLojCal)) .And. DUO->DUO_FOBDIR == '1' .And. !Empty(cCliCal) .And. !Empty(cLojCal)
			lFOBDIR := .T.
		EndIf
		If lFOBDIR
			(cAliasQry)->(DbCloseArea())
			cAliasQry   := GetNextAlias()

			cQuery := " SELECT "
			cQuery += " AAM.R_E_C_N_O_ RECAAM, AAM.AAM_CONTRT, AAM.AAM_CPAGPV, AAM.AAM_SELSER, AAM.AAM_CODCLI, AAM.AAM_LOJA, AAM.AAM_TIPFRE "
			cQuery += ", AAM.AAM_AGRNFC, AAM.AAM_TAXCTR, AAM.AAM_PESCTR, AAM.AAM_NFCTR, AAM.AAM_AJUOBR  "
			cQuery += ", AAM.AAM_PRCPRD "
			If (AAM->(ColumnPos('AAM_ESTAGR')) > 0)
				cQuery += ", AAM.AAM_ESTAGR "
			EndIf

			cQuery += ", DDA.DDA_ITEM  , DDA.DDA_CODNEG, DDA.DDA_SERVIC, DDA.DDA_FATCUB, DDA.DDA_TABFRE, DDA.DDA_TIPTAB, DDA.DDA_TABALT, DDA.DDA_TIPALT "
			cQuery += ", DDA.DDA_PESO  , DDA.DDA_PESOM3, DDA.DDA_QTDVOL, DDA.DDA_VALMER, DDA.DDA_VALFIX, DDA.DDA_FIXVAR, DDA.DDA_PORTMS, DDA.DDA_EDITMS "
			cQuery += ", DDA.DDA_DIACOL, DDA.DDA_AGEVIR, DDA.DDA_SRVCOL, DDA.DDA_TIPOPE "
			cQuery += ", DDA.DDA_ADIDOC, DDA.DDA_PRORAT, DDA.DDA_CRIRAT, DDA.DDA_BACRAT, DDA.DDA_CRDVFA, DDA.DDA_CRDVDC, DDA.DDA_VALCOL, DDA.DDA_CRDVHV "

			If lCpoSerie
				cQuery += ", DDA.DDA_SERIE "
			EndIf

			cQuery += ", DDC.DDC_ITEM  , DDC.DDC_CODNEG, DDC.DDC_TPCONT, DDC.DDC_INIVIG, DDC.DDC_FIMVIG, DDC.DDC_STATUS "
			cQuery += ", DDC.DDC_AGEVIR, DDC.DDC_SRVCOL, DDC.DDC_TIPOPE"
			cQuery += ", DDC.DDC_ADIDOC, DDC.DDC_PRORAT, DDC.DDC_CRIRAT, DDC.DDC_BACRAT, DDC.DDC_VALCOL, DDC.DDC_CRDVHV "

			If lCpoSerie
				cQuery += ", DDC.DDC_SERIE "
			EndIf

			cQuery += ", DDA.DDA_FIXVAR "
			cQuery += "    FROM "
			cQuery += RetSqlName("AAM") + " AAM, "
			cQuery += RetSqlName("DDA") + " DDA, "
			If Empty(cCodNeg)
				cQuery += RetSqlName("DDB") + " DDB,"
			EndIf
			cQuery += RetSqlName("DDC") + " DDC "

			cQuery += "    WHERE AAM.AAM_FILIAL = '" + xFilial("AAM") + "' "
			cQuery += "      AND AAM.AAM_CODCLI = '" + cCliCal + "' "
			cQuery += "      AND AAM.AAM_LOJA   = '" + cLojCal+ "' "
			cQuery += "      AND AAM.AAM_STATUS = '1' "
			cQuery += " AND AAM.AAM_CONTRT <> ' ' "
			cQuery += "      AND ( AAM.AAM_TIPFRE = '3' "
			cQuery += "       OR   AAM.AAM_TIPFRE = '" + cTipFre + "' ) "
			cQuery += "      AND ( AAM.AAM_FIMVIG = ' ' "
			cQuery += "       OR ( AAM.AAM_INIVIG <= '" + DtoS(dData) + "' AND AAM.AAM_FIMVIG >= '" + DtoS(dData) + "' ) ) "
			cQuery += "      AND AAM.D_E_L_E_T_ = ' ' "
			cQuery += "      AND DDA.DDA_FILIAL = '" + xFilial("DDA") + "' "
			cQuery += "      AND DDA.DDA_NCONTR = AAM.AAM_CONTRT "

			If Empty(cCodNeg)
				cQuery += "      AND DDB.DDB_FILIAL = '" + xFilial("DDB") + "' "
				cQuery += "      AND DDB.DDB_CODNEG = DDA.DDA_CODNEG   "
				cQuery += "      AND DDB.D_E_L_E_T_ = ' ' "
			Else
				cQuery += "      AND DDA.DDA_CODNEG = '" + cCodNeg + "' "
			EndIf

			If !Empty(cServic)
				cQuery += "      AND DDA.DDA_SERVIC = '" + cServic + "' "
			EndIf

			cQuery += "      AND DDA.D_E_L_E_T_ = ' ' "
			cQuery += "      AND DDC.DDC_FILIAL = '" + xFilial("DDC") + "' "
			cQuery += "      AND DDC.DDC_NCONTR = DDA.DDA_NCONTR "
			cQuery += "      AND DDC.DDC_CODNEG = DDA.DDA_CODNEG "
			cQuery += "      AND DDC.DDC_STATUS = '1' "
			cQuery += "      AND DDC.DDC_INIVIG <= '" + DtoS(dData) + "' "
			cQuery += "      AND ( DDC.DDC_FIMVIG = ' ' "
			cQuery += "      OR ( '" + DtoS(dData) + "' BETWEEN DDC.DDC_INIVIG AND DDC.DDC_FIMVIG ) ) "
			cQuery += "      AND DDC.D_E_L_E_T_ = ' ' "

			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			If (cAliasQry)->(!Eof())
				AAM->( dbGoto( (cAliasQry)->RECAAM ) )
				lAchou  := .T.
			EndIf
		EndIf
	EndIf

	If lAchou
		DC5->( DbSetOrder( 1 ) )
		DC5->( MsSeek( xFilial('DC5') + cServic ) )

		//-- Se nao achar perfil para o cliente cCliente, posiciona no perfil do cliente generico
		aPerfil := TmsPerfil(cCliente,cLoja,,,cCliRem,cLojRem,cCliDes,cLojDes)
		If	! Empty(aPerfil)
			If Empty(cCliGen)
				cCliGen := SuperGetMv("MV_CLIGEN",,"")
			EndIf
			//-- Sera considerado o perfil do cliente, qdo nao encontrar os campos de calculo do AAM ou
			//-- se for utilizar o Contrato do cliente generico.
			If 	(  lCliGen .And. cCliGen+cLojGen <> aPerfil[44]+aPerfil[45] ) .Or. ;
				( !lCliGen .And. cCliGen+cLojGen <> aPerfil[44]+aPerfil[45] .And. cCliente+cLoja <> aPerfil[44]+aPerfil[45] )
				cAgrNfc  := aPerfil[22] //-- Agrupa NF ?
				cPesCtr  := aPerfil[20] //-- Peso Max. por CTRC
				cNFCtr   := aPerfil[18] //-- Qtde. de Nfs por CTRC
				cAjuObr  := aPerfil[19] //-- Ajuste Obrigatorio ?
				cTaxCtr  := aPerfil[16] //-- Taxa por CTRC ?
				cPrcProd := aPerfil[46] //-- Utiliza produto para calculo
				cEstAgr  := aPerfil[57] //-- Estorno Frete Agrupado
			Else
				cAgrNfc := (cAliasQry)->AAM_AGRNFC //-- Agrupa NF ?
				cPesCtr := (cAliasQry)->AAM_PESCTR //-- Peso Max. por CTRC
				cNFCtr  := (cAliasQry)->AAM_NFCTR  //-- Qtde. de Nfs por CTRC
				cAjuObr := (cAliasQry)->AAM_AJUOBR //-- Ajuste Obrigatorio ?
				cTaxCtr := (cAliasQry)->AAM_TAXCTR //-- Taxa por CTRC ?
				cEstAgr := Iif((cAliasQry)->(ColumnPos('AAM_ESTAGR'))>0,(cAliasQry)->AAM_ESTAGR,'1')
				If !Empty((cAliasQry)->AAM_PRCPRD)
					cPrcProd := (cAliasQry)->AAM_PRCPRD
				Else
					cPrcProd := Iif(lPrcProd,"1","2") //-- Utiliza produto para calculo
				EndIf
			EndIf

			cFixVar := (cAliasQry)->DDA_FIXVAR

			If lTMALTTAB
				aRet := ExecBlock("TMALTTAB",.F.,.F.,{cCliente,cLoja,cTipFre,cServic,cCodNeg})
				If ValType(aRet) == "A"
					If Len(aRet) == 2 .And. ValType(aRet[1]) == "C" .And. ValType(aRet[2]) == "C"
						cTabFre := aRet[1]
						cTipTab := aRet[2]
					EndIf
				EndIf
			EndIf

			If Empty(cContrReen)  //Se o Contrato estiver alimentado, que serve para CTRC de Reentrega e Complemento, validar se a tabela está na vigencia.
				If lVigTabFre .And. (Empty(cTabFre) .Or. Empty(cTipTab))
					While (cAliasQry)->(!Eof())
						cTabFre := (cAliasQry)->DDA_TABFRE
						cTipTab := (cAliasQry)->DDA_TIPTAB
						If TMSTbAtiva( cTabFre, cTipTab, .F.)
							Exit
						Else
							(cAliasQry)->(DbSkip())
						EndIf
					EndDo
				EndIf
			Else
				cTabFre := (cAliasQry)->DDA_TABFRE
				cTipTab := (cAliasQry)->DDA_TIPTAB
			EndIf

			If (cAliasQry)->(!Eof())
				//-- Verifica se houve alteracao de cliente/loja
				lCliOri := cCliOri+cLojOri == cCliente+cLoja

				aDadosDDA := {}	//-- Serviço de Negociação do Contrato
				aDadosDDC := {}	//-- Negociação do Contrato
				aDadosDDP := {}	//-- Critério de Rateio Fixo

				Aadd(aDadosDDA,{(cAliasQry)->DDA_ITEM,;		//-- [01] Item
								(cAliasQry)->DDA_CODNEG,;	//-- [02] Código da Negociação
								(cAliasQry)->DDA_SERVIC,;	//-- [03] Serviço de Negociação
								(cAliasQry)->DDA_FATCUB,;	//-- [04] Fator de Cubagem
								(cAliasQry)->DDA_TABFRE,;	//-- [05] Tabela de Frete a Receber
								(cAliasQry)->DDA_TIPTAB,;	//-- [06] Tipo de Tabela de Frete a Receber
								(cAliasQry)->DDA_TABALT,;	//-- [07] Tabela Alternativa de Frete a Receber
								(cAliasQry)->DDA_TIPALT,;	//-- [08] Tipo de Tabela Alternativa de Frete a Receber
								(cAliasQry)->DDA_PESO,;		//-- [09] Limite de Peso Real para Serviço Automático
								(cAliasQry)->DDA_PESOM3,;	//-- [10] Limite de Peso Cubado para Serviço Automático
								(cAliasQry)->DDA_QTDVOL,;	//-- [11] Limite de Quantidade de Volumes para Serviço Automático
								(cAliasQry)->DDA_VALMER,;	//-- [12] Limite de Valor de Mercadoria para Serviço Automático
								(cAliasQry)->DDA_VALFIX,;	//-- [13] Valor Fixo do Contrato
								(cAliasQry)->DDA_FIXVAR,;	//-- [14] Cobra Fixo ou Variável 1=Fixo; 2=Variavel
								(cAliasQry)->DDA_PORTMS,;	//-- [15] Utiliza no Portal TMS 1=Sim; 2=Nao
								(cAliasQry)->DDA_EDITMS,;	//-- [16] Utiliza no EDI TMS 1=Sim; 2=Nao
								(cAliasQry)->DDA_DIACOL,;	//-- [17] Dias da semana para coleta automática
								(cAliasQry)->DDA_SRVCOL,;	//-- [18] Seviço Automatico de Coleta
								(cAliasQry)->DDA_AGEVIR,;	//-- [19] Indica se gera agendamento automatico na entrada de nota e coleta
								(cAliasQry)->DDA_TIPOPE,;  //-- [20] Tipo de operação 
								IIf(lCpoSerie, (cAliasQry)->DDA_SERIE, "")})	//[21] Serie Documento

				Aadd(aDadosDDC,{(cAliasQry)->DDC_ITEM,;		//-- [01] Item
								(cAliasQry)->DDC_CODNEG,;	//-- [02] Codigo da Negociação
								(cAliasQry)->DDC_TPCONT,;	//-- [03] Tipo de Contrato 1=Vitalicio; 2=Tempo Determinado
								(cAliasQry)->DDC_INIVIG,;	//-- [04] Inicio de Vigência
								(cAliasQry)->DDC_FIMVIG,;	//-- [05] Fim de Vigência
								(cAliasQry)->DDC_STATUS,;	//-- [06] Status da Negociação 1=Ativa; 2=Suspensa; 3=Encerrada; 4=Cancelada
								(cAliasQry)->DDC_AGEVIR,;	//-- [07] Indica se gera agendamento automatico na entrada de nota e coleta
								(cAliasQry)->DDC_SRVCOL,;	//-- [08] Indica se gera agendamento automatico na entrada de nota e coleta
								(cAliasQry)->DDC_TIPOPE,;	//-- [09] Tipo de operação
								IIf(lCpoSerie, (cAliasQry)->DDC_SERIE, "")})	//[21] Serie Documento



				If !Empty((cAliasQry)->DDA_BACRAT) .And. (cAliasQry)->DDA_BACRAT <> '1'
					cProRateio:= (cAliasQry)->DDA_PRORAT
					cCriRateio:= (cAliasQry)->DDA_CRIRAT
					cBacRateio:= (cAliasQry)->DDA_BACRAT
					cValCol   := (cAliasQry)->DDA_VALCOL

				ElseIf !Empty((cAliasQry)->DDC_BACRAT) .And. (cAliasQry)->DDC_BACRAT <> '1'
					nAdiDoc   := (cAliasQry)->DDC_ADIDOC
					cProRateio:= (cAliasQry)->DDC_PRORAT
					cCriRateio:= (cAliasQry)->DDC_CRIRAT
					cBacRateio:= (cAliasQry)->DDC_BACRAT
					cValCol   := (cAliasQry)->DDC_VALCOL
				EndIf

				nAdiDoc:= (cAliasQry)->DDA_ADIDOC
				cCrDvFa:= (cAliasQry)->DDA_CRDVFA
				cCrDvDc:= (cAliasQry)->DDA_CRDVDC

				If nAdiDoc == 0
					nAdiDoc:= (cAliasQry)->DDC_ADIDOC
				EndIf
				If DDA->(ColumnPos('DDA_CRDVHV')) > 0
					cCrDvHv:= (cAliasQry)->DDA_CRDVHV
					If cCrDvHv == '0'  //Nao Utiliza
						cCrDvHv:= (cAliasQry)->DDC_CRDVHV
					EndIf
				EndIf


				//-- Formato do vetor aRetorno
				AAdd(aRetorno,{	(cAliasQry)->AAM_CONTRT,;		//-- [01] = AAM->AAM_CONTRT	Numero do Contrato
								(cAliasQry)->DDA_FATCUB,;		//-- [02] = DDA->DDA_FATCUB	Fator de Cubagem
								cTabFre,;						//-- [03] = DUX->DUX_TABFRE	Tabela de Frete
								cTipTab,;						//-- [04] = DUX->DUX_TIPTAB	Tipo da Tabela de Frete
								DC5->DC5_TABSEG,;				//-- [05] = DC5->DC5_TABSEG	Tabela de Seguro
								aPerfil[1],;					//-- [06] = aPerfil[1]			Cliente Agrupamento
								aPerfil[2],;					//-- [07] = aPerfil[2]			Loja do Cliente Agrupamento
								cNFCTR,;						//-- [08] = aPerfil[18]			Qtde. NFs por CTRC
								(cAliasQry)->AAM_CPAGPV,;		//-- [09] = AAM->AAM_CPAGPV	Condicao de Pagamento para geracao do Pedido de Venda
								DC5->DC5_DESC1,;				//-- [10] = DC5->DC5_DESC1		1o Desconto na cotacao de frete
								DC5->DC5_DESC2,;				//-- [11] = DC5->DC5_DESC2		2o Desconto
								DC5->DC5_DESC3,;				//-- [12] = DC5->DC5_DESC3		3o Desconto
								DC5->DC5_DESC4,;				//-- [13] = DC5->DC5_DESC4		4o Desconto
								DC5->DC5_TPTSEG,;				//-- [14] = DC5->DC5_TPTSEG	Tipo da Tabela de Seguro
								(cAliasQry)->DDA_TABALT,;		//-- [15] = DDA->DDA_TABALT	Tabela Alternativa
								(cAliasQry)->DDA_TIPALT,;		//-- [16] = DDA->DDA_TIPALT	Tipo da Tabela Alternativa
								lCliGen,;						//-- [17] = lCliGen				.T. Contrato do Cliente Generico
								cAjuObr,;						//-- [18] = aPerfil[19]			Ajuste Obrigatorio
								aPerfil[3],;					//-- [19] = aPerfil[3]			Condicao de Frete SX5(M4)
								cPesCTR,;						//-- [20] = aPerfil[20]			Peso Maximo por CTRC
								(cAliasQry)->AAM_SELSER,;		//-- [21] = AAM->AAM_SELSER	Selecao de Servicos (1=Digitado / 2=Automatica)
								cAgrNfc,;						//-- [22] = aPerfil[22]			Determina se a geracao de documentos ira ou nao,; considerar as quebras por numero de notas fiscais por CTRC e peso maximo por CTRC
								cTaxCtr,;						//-- [23] = aPerfil[16]			Taxa por CTRC ?
								cPrcProd,;						//-- [24] = DUX->DUX_PRCPROD	Considera Produto para cálculo
								(cAliasQry)->AAM_CODCLI,;		//-- [25] = AAM->AAM_CODCLI	Codigo do Cliente
								(cAliasQry)->AAM_LOJA,;			//-- [26] = AAM->AAM_LOJA		Loja do Cliente
								(cAliasQry)->DDA_SERVIC,;		//-- [27] = DDA->DDA_SERVIC	Codigo do Servico
								aPerfil[49],;					//-- [28] = aPerfil[80]			Devedor Paga TDA (1=Coleta; 2=Entrega; 3=Coleta e Entrega; 4=Coleta ou Entrega)
								cFixVAR,;						//-- [29] = cFixVar				Valor Fixo/Variavel na cobrança de veiculo dedicado
								(cAliasQry)->AAM_TIPFRE,;		//-- [30] = Tipo do Frete (1-CIF / 2-FOB / 3-CIF & FOB)
								cCliRem,;						//-- [31] = Cliente Remetente		(Apenas Informativo)
								cLojRem,;						//-- [32] = Loja do Remetente		(Apenas Informativo)
								cCliDes,;						//-- [33] = Cliente Destinatario	(Apenas Informativo)
								cLojDes,;						//-- [34] = Loja do Destinatario	(Apenas Informativo)
								cCliDev,;						//-- [35] = Cliente Devedor			(Apenas Informativo)
								cLojDev,;						//-- [36] = Loja do Devedor			(Apenas Informativo)
								cTipoNf,;						//-- [37] = Loja do Devedor			(Apenas Informativo)
								lCliOri,;						//-- [38] = Hove alteracao de cliente/loja por PE
								nAdiDoc,;						//-- [39] = A partir de qual Documento devera ser cobrada a Taxa Adicional
								cProRateio,;					//-- [40] = Criterio de Rateio
								cCriRateio,;					//-- [41] = Criterio de Calculo de Rateio
								cBacRateio,;					//-- [42] = Base de Calculo de Rateio
								aDadosDDA,;						//-- [43] = Vetor com o Serviço de Negociação do Contrato
								aDadosDDC,;						//-- [44] = Vetor com a Negociação do Contrato
								aDadosDDP,;						//-- [45] = Vetor com os Rateios Fixos
								Iif(lCmpRatNew,cCrDvFa,''),;	//-- [46] = Criterio Devedor Faltante
								Iif(lCmpRatNew,cCrDvDc,''),;	//-- [47] = Criterio Prop.Vlr.Coleta
								Iif(lCmpRatNew,cValCol,''),; 	//-- [48] = Valoriza Coleta Nao Realizada
								Iif(!Empty((cAliasQry)->DDA_AGEVIR),(cAliasQry)->DDA_AGEVIR,(cAliasQry)->DDC_AGEVIR),;	//-- [49] = AGEVIR	Agendamento virtual
								Iif(!Empty((cAliasQry)->DDA_SRVCOL),(cAliasQry)->DDA_SRVCOL,(cAliasQry)->DDC_SRVCOL),;	//-- [50] = SRVCOL	Serv.Coleta
								Iif(lCmpRatNew,cCrDvHv,''),; //-- [51] = Criterio Herda Valor
								cEstAgr,; 						//-- [52] = Estorno Frete Agrupado
								Iif(Len(aPerfil) >= 65, aPerfil[65], ' ') }) //-- [53] = aPerfil[65] Usa TDA por Região				 

				nTamArray := Len(aRetorno[1])

				If lTmsContrat
					aRet := Execblock("TMSCONTRAT",.F.,.F.,aRetorno)
					If ValType(aRet) <> "A" .Or.  Len(aRet) == 0  .Or. Len(aRet[1]) <> nTamArray
						lRet := .F.
					EndIf
					If lRet
						For nCount := 1 To Len(aRet[1])
							If ValType(aRetorno[1,nCount]) <> ValType(aRet[1,nCount])
								lRet := .F.
								Exit
							EndIf
						Next nCount
						If lRet
							SA1->( DbSetOrder(1) )
							If lRet .And. aRet[1,6] + aRet[1,7] <> aRetorno[1,6] + aRetorno[1,7]
								If !SA1->( MsSeek( xFilial("SA1") + aRet[1,6] + aRet[1,7] ) )
									lRet := .F.
								EndIf
							EndIf
						EndIf
						If lRet
							aRetorno := {}
							aRetorno := aClone(aRet)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
       If Empty(cContrReen) //Contrato utilizado para reentrega pode estar vencido, e portanto nao pode ser utilizado para outras operacoes.
			SetContrat( cCliente, cLoja, dData, cServic, cTipFre, cVigCon, cTipTra, cCodNeg, aRetorno)
		EndIF
	Else
		If lHelp .AND. !IsInCallStack("TMSA180")
			Help('',1,'TMSXFUNA08CLI',,STR0341 + cCliente + "/" + cLoja,01,05,,,,,/*aSoluc*/) //| Contrato do cliente nao foi encontrado. código:  ...
		EndIf
	EndIf

	//-- Finaliza arquivo de trabalho
	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf
EndIf

RestArea( aAreaAAM )
Return( aRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SetContrat³ Autor ³ Adalberto S.M         ³ Data ³12.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adicionar informacoes do contrato, funcao TMSContrat() ao   ³±±
±±³          ³vetor aTMSContrat                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SetContrat( ExpC1, ExpC2, ExpD1, ExpC3, ExpC4, ExpC5, ExpC6,³±±
±±³          ³            ExpC7, ExpA1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Cliente                                   ³±±
±±³          ³ExpC2 - Loja do Cliente                                     ³±±
±±³          ³ExpD1 - DataBase                                            ³±±
±±³          ³ExpC3 - Servico                                             ³±±
±±³          ³ExpC4 - Tipo de Frete (CIF / FOB)                           ³±±
±±³          ³ExpC5 - 1 = Considera a vigencia atual do contrato          ³±±
±±³          ³        2 = Considera a proxima vigencia do contrato        ³±±
±±³          ³ExpC6 - Tipo de Transporte                                  ³±±
±±³          ³ExpC7 - Codigo da Negociacao                                ³±±
±±³          ³ExpA1 - Vetor contendo todas as informacoes do Contrato.    ³±±
±±³          ³        Essas informacoes sao geradas pela funcao TMSContrat³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetContrat( cCliente, cLoja, dData, cServic, cTipFre, cVigCon, cTipTra, cCodNeg, aContrato)
	Default aContrato	:= {}
	Default cCliente	:= ""
	Default cLoja		:= ""
	Default dData		:= ""
	Default cServic		:= ""
	Default cTipFre		:= ""
	Default cVigCon		:= ""
	Default cTipTra		:= ""
	Default cCodNeg     := ""

	If ValType(aTMSContrat) <> 'A'
		Static aTMSContrat := {}
	EndIf

    /////////////////////////////////////////////////////////////////////////////
    // Manter o vetor aContrato sempre na ultima posicao do vetor aTMSContrat, //
    // para que a funcao GetContrat() funcione corretamente.                   //
    /////////////////////////////////////////////////////////////////////////////
	If Len(aContrato) > 0
		Aadd( aTMSContrat, { cCliente, cLoja, DtoS(dData), cServic, cTipFre, cVigCon, cTipTra, cCodNeg, aContrato } )
	EndIf
Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetContrat³ Autor ³ Adalberto S.M         ³ Data ³12.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Requisitar informacoes do contrato existentes no vetor      ³±±
±±³          ³aTMSContrat. O intuito dessa rotina eh reaproveitar as in-  ³±±
±±³          ³formacoes ja processadas pela funcao TMSContrat(), sem que  ³±±
±±³          ³haja novamente uma busca na base de dados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SetContrat( ExpC1, ExpC2, ExpD1, ExpC3, ExpC4, ExpC5, ExpC6,³±±
±±³          ³            ExpC7, ExpA1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Cliente                                   ³±±
±±³          ³ExpC2 - Loja do Cliente                                     ³±±
±±³          ³ExpD1 - DataBase                                            ³±±
±±³          ³ExpC3 - Servico                                             ³±±
±±³          ³ExpC4 - Tipo de Frete (CIF / FOB)                           ³±±
±±³          ³ExpC5 - 1 = Considera a vigencia atual do contrato          ³±±
±±³          ³        2 = Considera a proxima vigencia do contrato        ³±±
±±³          ³ExpC6 - Tipo de Transporte                                  ³±±
±±³          ³ExpC7 - Codigo da Negociacao                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo dados do Contrato                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetContrat( cCliente, cLoja, dData, cServic, cTipFre, cVigCon, cTipTra, cCodNeg)
	Local aRetorno	:= {}
	Local nPosicao	:= 0
	Default cCliente	:= ""
	Default cLoja		:= ""
	Default dData		:= ""
	Default cServic		:= ""
	Default cTipFre		:= ""
	Default cVigCon		:= ""
	Default cTipTra		:= ""
	Default cCodNeg     := ""

	If ValType(aTMSContrat) <> 'A'
		Static aTMSContrat := {}
	EndIf

	If Len(aTMSContrat) > 0
		aRetorno := {}
		nPosicao := Ascan( aTMSContrat, { |x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[8] == cCliente + cLoja + DtoS(dData) + cServic + cTipFre + cVigCon + cTipTra + cCodNeg } )

		If nPosicao > 0
			aRetorno := aTMSContrat[ nPosicao, Len(aTMSContrat[ nPosicao] ) ]
		EndIf
	EndIf
Return ( aRetorno )


/*----------------------------------------------------------------------------------------------------
{Protheus.doc} TMSLimpaContr
Limpa os contratos armazenado em memória no array aTMSContrat
Uso Interno.

@protected
@author Israel A Possoli
@since 13/04/2016
@version 1.0
------------------------------------------------------------------------------------------------------*/
Function TMSLimpaContr()
	If ValType(aTMSContrat) <> 'A'
		Static aTMSContrat := {}
		Return
	EndIf

	aTMSContrat := {}
	aSize(aTMSContrat, 0)
Return (Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsVlFaixa³ Autor ³ Alex Egydio           ³ Data ³16.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula valor do componente e analisa minimo de excesso    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsVlFaixa                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor indicando onde ocorreu erros no calculo      ³±±
±±³          ³ ExpC1 = Codigo da tabela de frete                          ³±±
±±³          ³ ExpC2 = Tipo da tabela de frete                            ³±±
±±³          ³ ExpC3 = Tabela de tarifa                                   ³±±
±±³          ³ ExpC4 = Regiao origem                                      ³±±
±±³          ³ ExpC5 = Regiao destino                                     ³±±
±±³          ³ ExpC6 = Codigo do cliente                                  ³±±
±±³          ³ ExpC7 = Loja do cliente                                    ³±±
±±³          ³ ExpC8 = Sequencia da tabela de frete                       ³±±
±±³          ³ ExpC9 = Produto                                            ³±±
±±³          ³ ExpCA = Servico                                            ³±±
±±³          ³ ExpCB = Codigo do componente                               ³±±
±±³          ³ ExpCC = Tipo do componente                                 ³±±
±±³          ³ ExpCD = Componente de frete que determina o peso cobrado   ³±±
±±³          ³ ExpCE = Determina se o calculo sera pela fracao ou inteiro ³±±
±±³          ³ ExpCF = Determina se o componente eh obrigatorio           ³±±
±±³          ³ ExpL1 = Preenche o vetor indicando onde ocorreu erros .T.  ³±±
±±³          ³ ExpL2 = .T. Calculo pelo peso real, procurar na faixa peso ³±±
±±³          ³         .F. Calculo pelo peso cubado, procurar na faixa    ³±±
±±³          ³         fator peso.                                        ³±±
±±³          ³ ExpN1 = Estabelece o valor minimo do componente ( @ )      ³±±
±±³          ³ ExpN2 = Peso cobrado ( @ )                                 ³±±
±±³          ³ ExpN3 = Tamanho do campo DT3_TIPFAI                        ³±±
±±³          ³ ExpN4 = Valor base para calculo                            ³±±
±±³          ³ ExpN5 = Percentual de cobranca                             ³±±
±±³          ³ ExpN6 = Valor da Mercadoria                                ³±±
±±³          ³ ExpCG = Regiao Origem da Tabela Mae                        ³±±
±±³          ³ ExpCH = Regiao Destino da Tabela Mae                       ³±±
±±³          ³ ExpCI = Produto da Tabela Mae                              ³±±
±±³          ³ ExpN7 = Quantidade de Documentos                           ³±±
±±³          ³ ExpN8 = Valor base calcula sobre.                          ³±±
±±³          ³ ExpN9 = Valor base sub-faixa.                              ³±±
±±³          ³ ExpNA = Tipo de sub-faixa.                                 ³±±
±±³          ³ ExpA2 = Vetor contendo a Faixa da Tabela de Cada Componente³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Valor do componente                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsVlFaixa( aMsgErr,cTabFre,cTipTab,cTabTar,cCdrOri,cCdrDes,cCodCli,cLojCli,cSeqTab,cCodPro,cServic,;
cCodPas,cFaixa,cPesCob,cFracao,cComObr,lMsgErr,lPesoReal,nValMin,nPesoCob,nLenTpFai,nBaseCal,nPerCob,nValMer,;
cRgOTab, cRgDTab, cPrdTab, nQtdDco, nBaseSobre, nBaseCalFx2, cFaixa2, aFaixaTab, cLotNfc, nValMax, cCliDes, cLojDes, nRecDT3, cCodNeg, cRecDT1, cRecDTG )

Local cSeekDTK    := ''
Local cSeekDVO    := ''
Local nRet        := 0
Local nExcMin     := 0
Local nExcede     := 0
Local nVFBase     := 0
Local nVlrExc     := 0
Local nInterv     := 0
Local aVeiculos   := {}
Local cFilOri     := ""
//-- Operadoras de Frota/Vale-Pedagio
Local lTMSOPdg    := SuperGetMV('MV_TMSOPDG',,'0') $ '1|2'
Local lFailPdg    := .F.
Local cQuery      := ""
Local cAliasQry   := ""
Local aAreaDTR    := DTR->(GetArea())
Local lTipFx9     := .F.
Local lTercRbq    := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local lRateio     := .f.

Default nBaseCalFx2 := 0
Default cFaixa2     := ""
Default aFaixaTab   := {}
Default cLotNfc     := ""
Default cCliDes     := ""
Default cLojDes     := ""
DeFault nValMax     := 9999999999.99
DeFault nRecDT3     := 0
Default cCodNeg     := ""

If nRecDT3 == 0
	lTipFx9 := ( My_Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_TIPFAI") == StrZero(9,Len(DT3->DT3_TIPFAI)) )
Else
	DT3->( dbGoto(nRecDT3) )
	lTipFx9 := ( DT3->DT3_TIPFAI == StrZero(9,Len(DT3->DT3_TIPFAI)) )
EndIf

//-- Verifica se o componente e Praca de Pedagio
If !Empty(cLotNfc) .And. lTipFx9

	//-- Verifica Configurações De Rateio
	lRateio	:= 	DTP->(ColumnPos("DTP_ROTA")) > 0 .And.;				//-- Testa Existencia Do Campo No Dicionário
					TMSLRateio( DTP->DTP_FILORI, DTP->DTP_LOTNFC )	//-- Testa Se é Lote De Rateio

	nRet := 0
	cFilOri := cFilAnt
	//-- Obter os Veiculos e a Rota
	DTR->(dbSetOrder(1))
	cAliasQry := GetNextAlias()
	If lTercRbq
		cQuery := "   SELECT DTR_CODVEI,DTR_QTDEIX, DTR_CODRB1, DTR_CODRB2, DTR_CODRB3, DTR_CODOPE, DTQ_ROTA"
	Else
		cQuery := "   SELECT DTR_CODVEI,DTR_QTDEIX, DTR_CODRB1, DTR_CODRB2, DTR_CODOPE, DTQ_ROTA"
	EndIf

	//-- Inclui campos De Rateio
	If lRateio
		cQuery += ", DTP_ROTA "
	EndIf

	cQuery += "     FROM " + RetSqlName("DTP") +" DTP , "+ RetSqlName("DTQ") +" DTQ , " + RetSqlName("DTR") +" DTR "
	//Condicoes da tabela DTP FILIAL+FILORI+LOTNFC E DTP_VIAGEM PREENCHIDO
	cQuery += "    WHERE DTP_FILIAL = '" + xFilial("DTP") + "'"
	cQuery += "      AND DTP_FILORI = '" + cFilOri + "' "
	cQuery += "      AND DTP_LOTNFC = '" + cLotNfc + "' "
	cQuery += "      AND DTP_VIAGEM != ' ' "     //SOMENTE REGISTROS COM DTP_VIAGEM PREENCHIDOS INTERESSAM
	cQuery += "      AND DTP.D_E_L_E_T_ = ' ' "
	//LINKAR TABELA DTP COM TABELA DTQ PELA CODIGO DA VIAGEM
	cQuery += "      AND DTQ_FILIAL = '" + xFilial("DTQ") + "'"
	cQuery += "      AND DTQ_FILORI = '" + cFilOri + "' "
	cQuery += "      AND DTQ_VIAGEM = DTP_VIAGEM "
	cQuery += "      AND DTQ.D_E_L_E_T_ = ' ' "
	//LINKAR TABELA DTQ COM TABELA DTR PELO CODIGO DA VIAGEM
	cQuery += "      AND DTR_FILIAL = '" + xFilial("DTR") + "'"
	cQuery += "      AND DTR_FILORI = '" + cFilOri + "' "
	cQuery += "      AND DTR_VIAGEM = DTQ_VIAGEM "
	cQuery += "      AND DTR.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY " + SqlOrder(DTR->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	While (cAliasQry)->(!Eof())
		aVeiculos := {}
		AAdd(aVeiculos,{(cAliasQry)->DTR_CODVEI,(cAliasQry)->DTR_QTDEIX,(cAliasQry)->DTR_QTDEIX})
		If !Empty((cAliasQry)->DTR_CODRB1)
			AAdd(aVeiculos,{(cAliasQry)->DTR_CODRB1,0,0})
			If !Empty((cAliasQry)->DTR_CODRB2)
				AAdd(aVeiculos,{(cAliasQry)->DTR_CODRB2,0,0})
			EndIf
			If lTercRbq
			If !Empty((cAliasQry)->DTR_CODRB3)
				AAdd(aVeiculos,{(cAliasQry)->DTR_CODRB3,0,0})
				EndIf
			EndIf
		EndIf

		If Len(aVeiculos) > 0

			//-- Se For Rateio Verifica Conteúdo Do Campo DTP_ROTA
			If lRateio .And. Empty((cAliasQry)->DTP_ROTA)
				Help(" ",1,"TMSXFUNA44") //-- O Conteúdo Do Campo DTP_ROTA Está Vazio Ou Inválido. Verifique As Configurações De Rateio No Contrato Do Cliente.
				nRet += 0
			Else
				//-- Chama a rotina de calculo do pedagio
				nRet += TmsCalPdg(aVeiculos,Iif( lRateio ,(cAliasQry)->DTP_ROTA,(cAliasQry)->DTQ_ROTA),IIF(lTMSOPdg, (cAliasQry)->DTR_CODOPE, ''),@lFailPdg)
			EndIf
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	RestArea( aAreaDTR )

Else
	//-- Complemento da tabela de frete
	DTK->(DbSetOrder(1)) //DTK_FILIAL+DTK_TABFRE+DTK_TIPTAB+DTK_CDRORI+DTK_CDRDES+DTK_CODPRO+DTK_CODPAS
	If cSeqTab == StrZero(0,Len(DVO->DVO_SEQTAB))
		cSeekDTK := xFilial('DTK') + cTabFre + cTipTab + cCdrOri + cCdrDes + cCodPro + cCodPas

		If	DTK->( MsSeek( cSeekDTK ) )
			//-- Minimo excesso
			nExcMin	:= DTK->DTK_EXCMIN
			//-- Valor minimo
			nValMin := DTK->DTK_VALMIN
			//-- Valor excedente
			nVlrExc	:= DTK->DTK_VALOR
			//-- Fracao excedente
			nInterv	:= DTK->DTK_INTERV
			//-- Valor Maximo
			IF DTK->DTK_VALMAX <> 0
				nValMax := DTK->DTK_VALMAX
			Else
				nValMax := 9999999999.99
			EndIf
		EndIf

	Else
		DVO->(DbSetOrder(2)) //-- DVO_FILIAL+DVO_CODCLI+DVO_LOJCLI+DVO_TABFRE+DVO_TIPTAB+DVO_CDRORI+DVO_CDRDES+DVO_SEQTAB+DVO_CODPRO+DVO_SERVIC+DVO_CODPAS quando for indice 1 ou
											 //-- DVO_FILIAL+DVO_CODCLI+DVO_LOJCLI+DVO_TABFRE+DVO_TIPTAB+DVO_CDRORI+DVO_CDRDES+DVO_SEQTAB+DVO_CODPRO+DVO_CODNEG+DVO_SERVIC+DVO_CODPAS quando for indice 2
		cSeekDVO := xFilial('DVO') +  cCodCli + cLojCli + cTabFre + cTipTab + cCdrOri + cCdrDes + cSeqTab + cCodPro + cCodNeg + cServic + cCodPas
		If DVO->( MsSeek( cSeekDVO ) )

			cSeekDTK := xFilial('DTK') + cTabFre + cTipTab + cRgOTab + cRgDTab + IIF(Empty(AllTrim(cPrdTab)),cCodPro,cPrdTab) + cCodPas
			If	DTK->( MsSeek( cSeekDTK ) )
				//-- Minimo excesso
				nExcMin	:= DVO->DVO_EXCMIN
				//-- Valor minimo
				nValMin :=  DTK->DTK_VALMIN * (DVO->DVO_PERMIN / 100 )
				//-- Valor excedente
				nVlrExc	:= DTK->DTK_VALOR * (DVO->DVO_PERAJU / 100 )
				//-- Fracao excedente
				nInterv	:= DVO->DVO_INTERV
				//-- Valor maximo
				nValMax :=  DTK->DTK_VALMAX * (DVO->DVO_PERMAX / 100 )
				IF nValMax == 0
					nValMax := 9999999999.99
				EndIf
			Else
				AAdd( aMsgErr, { STR0034 + cTabFre + '-' + cTipTab + STR0035 + cCdrOri + ' / ' + STR0036 + cCdrDes + ' / ' + STR0037 + cCodPro , '23', 'TMSA010()' } ) //"Complemento da Tabela de Frete Nao Encontrado. Tabela : "###" Origem: "###"Destino :"###"Produto :"
			EndIf
		EndIf
	EndIf

	//-- Sem minimo de excesso
	If	Empty(nExcMin) .Or. Iif(nBaseCalFx2 > 0, nBaseCalFx2 <= nExcMin, nBaseCal <= nExcMin)

		//-- Valor da faixa referente a base de calculo
		nRet		:=	TmsRetVlFx(@aMsgErr,cTabFre,cTipTab,cTabTar,cCdrOri,cCdrDes,cCodCli,cLojCli,cSeqTab,cCodPro,cServic,;
						cCodPas,cFaixa,cPesCob,cFracao,cComObr,lMsgErr,lPesoReal,@nPesoCob,nLenTpFai,nBaseCal,nPerCob,nValmer,,nQtdDco,;
						nBaseSobre,nBaseCalFx2,cFaixa2,@aFaixaTab,1,cCliDes,cLojDes,cCodNeg,@cRecDT1,@cRecDTG)

	//-- Calcula o minimo de excesso
	Else

		//-- Qto ultrapassou do minimo de excesso
		If nBaseCalFx2 > 0
			nExcede := nBaseCalFx2 - nExcMin
		Else
			nExcede := nBaseSobre - nExcMin
		EndIf

		If	nVlrExc > 0 .Or. ( nBaseCal < nExcMin )
			//-- Valor da faixa referente a base de calculo
			nVFBase	:=	TmsRetVlFx(@aMsgErr,cTabFre,cTipTab,cTabTar,cCdrOri,cCdrDes,cCodCli,cLojCli,cSeqTab,cCodPro,cServic,;
							cCodPas,cFaixa,cPesCob,cFracao,cComObr,lMsgErr,lPesoReal,@nPesoCob,nLenTpFai,nBaseCal,nPerCob,nValmer,,nQtdDco,;
							nBaseSobre,nBaseCalFx2,cFaixa2,@aFaixaTab,1,cCliDes,cLojDes,cCodNeg,@cRecDT1,@cRecDTG)
			IF nVFBase > 0
				If nInterv > 0
					nRet := ( nExcede * ( nVlrExc / nInterv ) ) + nVFBase
				Else
					nRet := nVlrExc + nVFBase
				EndIf
			EndIf

		Else
			//-- Valor da faixa referente ao minimo de excesso
			If nBaseCalFx2 > 0
				nVFMinE	:=	TmsRetVlFx(@aMsgErr,cTabFre,cTipTab,cTabTar,cCdrOri,cCdrDes,cCodCli,cLojCli,cSeqTab,cCodPro,cServic,;
								cCodPas,cFaixa,cPesCob,cFracao,cComObr,lMsgErr,lPesoReal,@nPesoCob,nLenTpFai,nBaseCal,nPerCob,nValmer,,nQtdDco,;
								nExcMin,nExcMin,cFaixa2,@aFaixaTab,1,cCliDes,cLojDes,cCodNeg,@cRecDT1,@cRecDTG)
			Else
				nVFMinE	:=	TmsRetVlFx(@aMsgErr,cTabFre,cTipTab,cTabTar,cCdrOri,cCdrDes,cCodCli,cLojCli,cSeqTab,cCodPro,cServic,;
								cCodPas,cFaixa,cPesCob,cFracao,cComObr,lMsgErr,lPesoReal,@nPesoCob,nLenTpFai,nExcMin,nPerCob,nValmer,,nQtdDco,;
								nExcMin,,,@aFaixaTab,3,cCliDes,cLojDes,cCodNeg,@cRecDT1,@cRecDTG)
			EndIf

			If nExcede <= nExcMin
				//-- Valor da faixa referente a base de calculo
				nVFBase	:=	TmsRetVlFx(@aMsgErr,cTabFre,cTipTab,cTabTar,cCdrOri,cCdrDes,cCodCli,cLojCli,cSeqTab,cCodPro,cServic,;
								cCodPas,cFaixa,cPesCob,cFracao,cComObr,lMsgErr,lPesoReal,@nPesoCob,nLenTpFai,nBaseCal,nPerCob,nValmer,nExcMin,nQtdDco,;
								nBaseSobre,nBaseCalFx2,cFaixa2,@aFaixaTab,1,cCliDes,cLojDes,cCodNeg,@cRecDT1,@cRecDTG)
			Else
				//-- Valor da faixa referente a base de calculo
				If nBaseCalFx2 > 0
					nVFBase	:=	TmsRetVlFx(@aMsgErr,cTabFre,cTipTab,cTabTar,cCdrOri,cCdrDes,cCodCli,cLojCli,cSeqTab,cCodPro,cServic,;
									cCodPas,cFaixa,cPesCob,cFracao,cComObr,lMsgErr,lPesoReal,@nPesoCob,nLenTpFai,nBaseCal,nPerCob,nValmer,,nQtdDco,;
									nExcede,nExcede,cFaixa2,@aFaixaTab,1,cCliDes,cLojDes,cCodNeg,@cRecDT1,@cRecDTG)
				Else
					nVFBase	:=	TmsRetVlFx(@aMsgErr,cTabFre,cTipTab,cTabTar,cCdrOri,cCdrDes,cCodCli,cLojCli,cSeqTab,cCodPro,cServic,;
									cCodPas,cFaixa,cPesCob,cFracao,cComObr,lMsgErr,lPesoReal,@nPesoCob,nLenTpFai,nExcede,nPerCob,nValmer,,nQtdDco,;
									nExcede,,,@aFaixaTab,2,cCliDes,cLojDes,cCodNeg,@cRecDT1,@cRecDTG)
				EndIf
			EndIf

			nRet := ( nVFBase + nVFMinE )

		EndIf
	EndIf
EndIf

Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsRetVlFx³ Autor ³ Alex Egydio           ³ Data ³16.10.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa a faixa de valores da tabela                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsRetVlFx                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA01 = Vetor indicando onde ocorreu erros no calculo      ³±±
±±³          ³ ExpC02 = Codigo da tabela de frete                          ³±±
±±³          ³ ExpC03 = Tipo da tabela de frete                            ³±±
±±³          ³ ExpC04 = Tabela de tarifa                                   ³±±
±±³          ³ ExpC05 = Regiao origem                                      ³±±
±±³          ³ ExpC06 = Regiao destino                                     ³±±
±±³          ³ ExpC07 = Codigo do cliente                                  ³±±
±±³          ³ ExpC08 = Loja do cliente                                    ³±±
±±³          ³ ExpC09 = Sequencia da tabela de frete                       ³±±
±±³          ³ ExpC10 = Produto                                            ³±±
±±³          ³ ExpC11 = Servico                                            ³±±
±±³          ³ ExpC12 = Codigo do componente                               ³±±
±±³          ³ ExpC13 = Tipo do componente                                 ³±±
±±³          ³ ExpC14 = Componente de frete que determina o peso cobrado   ³±±
±±³          ³ ExpC15 = Determina se o calculo sera pela fracao ou inteiro ³±±
±±³          ³ ExpC16 = Determina se o componente eh obrigatorio           ³±±
±±³          ³ ExpL17 = Preenche o vetor indicando onde ocorreu erros .T.  ³±±
±±³          ³ ExpL18 = .T. Calculo pelo peso real, procurar na faixa peso ³±±
±±³          ³          .F. Calculo pelo peso cubado, procurar na faixa    ³±±
±±³          ³          fator peso.                                        ³±±
±±³          ³ ExpN19 = Peso cobrado ( @ )                                 ³±±
±±³          ³ ExpN20 = Tamanho do campo DT3_TIPFAI                        ³±±
±±³          ³ ExpN21 = Valor base para calculo                            ³±±
±±³          ³ ExpN22 = Percentual de cobranca                             ³±±
±±³          ³ ExpN23 = Valor da Mercadoria                                ³±±
±±³          ³ ExpN24 = Valor do minimo de excesso                         ³±±
±±³          ³ ExpN25 = Quantidade de Documentos                           ³±±
±±³          ³ ExpN26 = Base calcula sobre                                 ³±±
±±³          ³ ExpN27 = Valor base sub-faixa.                              ³±±
±±³          ³ ExpN28 = Tipo de sub-faixa.                                 ³±±
±±³          ³ ExpA29 = Vetor contendo a Faixa da Tabela de Cada Componente³±±
±±³          ³ ExpN30 = Tipo de Base de Calculo 1=Base Calculo;2=Excedente ³±±
±±³          ³          3=Minimo de Excesso                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Valor da faixa da tabela                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsRetVlFx(aMsgErr,cTabFre,cTipTab,cTabTar,cCdrOri,cCdrDes,cCodCli,cLojCli,cSeqTab,cCodPro,cServic,;
cCodPas,cFaixa,cPesCob,cFracao,cComObr,lMsgErr,lPesoReal,nPesoCob,nLenTpFai,nBaseCal,nPerCob,nValMer,nExcMin,;
nQtdDco,nBaseSobre,nBaseCalFx2,cFaixa2,aFaixaTab,nTpBase,cCliDes,cLojDes,cCodNeg,cRecDT1,cRecDTG)

Local cItemDVD      := Space(Len(DVD->DVD_ITEM))
Local cRgOTab       := Space(Len(DVD->DVD_RGOTAB))
Local cRgDTab       := Space(Len(DVD->DVD_RGDTAB))
Local cPrdTab       := Space(Len(DVD->DVD_PRDTAB))
Local lTarifa       := .F.
Local nRet          := 0
Local nFaixa        := 0
Local nPerAju       := 0
Local nInterv       := 0
Local lExistMsg     := .F.
Local lRet          := .F.
Local cSeek         := ""
Local bWhile        := { || .T. }
Local cItemDW2      := ""
Local cQuery        := ""
Local cAliasQry     := ""
Local aAreaDT1      := DT1->(GetArea())
Local aAreaDVD      := DVD->(GetArea())
Local aAreaDTG      := DTG->(GetArea())

Default nValMer     := 0
Default nExcMin     := 0
Default nQtdDco     := 0
Default nBaseCalFx2 := 0
Default cFaixa2     := ''
Default aFaixaTab   := {}
Default nTpBase     := 1 //--Padrao e Base de Calculo
Default cCliDes     := ""
Default cLojDes     := ""
Default cCodneg     := ""
//-- Tabela mae
If	cSeqTab == StrZero( 0, Len( DVC->DVC_SEQTAB ) )
	If Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_TIPFAI") <> "15" //-- Calculo por cliente destinatário

		If _oVlFxDT1 == Nil
			_oVlFxDT1 := FWPreparedStatement():New()

			cQuery := "   SELECT DT1_VALATE, DT1_FATPES, DT1_VALATE, DT1_INTERV, DT1_VALOR, DT1_TABFRE, DT1_TIPTAB, DT1_CDRORI, DT1_CDRDES, DT1_CODPRO, DT1_CODPAS, DT1_ITEM, R_E_C_N_O_ RECNO_DT1 "
			cQuery += "     FROM " + RetSqlName("DT1")
			cQuery += "    WHERE DT1_FILIAL = ? "
			cQuery += "      AND DT1_TABFRE = ? "
			cQuery += "      AND DT1_TIPTAB = ? "
			cQuery += "      AND DT1_CDRORI = ? "
			cQuery += "      AND DT1_CDRDES = ? "
			cQuery += "      AND DT1_CODPRO = ? "
			cQuery += "      AND DT1_CODPAS = ? "
			cQuery += "      AND D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY " + SqlOrder(DT1->(IndexKey()))
			cQuery := ChangeQuery(cQuery)

			_oVlFxDT1:SetQuery(cQuery)
		EndIf

		_oVlFxDT1:SetString(1,xFilial('DT1') )
		_oVlFxDT1:SetString(2,cTabFre)
		_oVlFxDT1:SetString(3,cTipTab )
		_oVlFxDT1:SetString(4,cCdrOri )
		_oVlFxDT1:SetString(5,cCdrDes )
		_oVlFxDT1:SetString(6,cCodPro )
		_oVlFxDT1:SetString(7,cCodPas )

		cQuery	:= _oVlFxDT1:getFixQuery()

		DT1->( DbSetOrder( 1 ) )
		cAliasQry := GetNextAlias()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

		If (cAliasQry)->(!Eof())

			While (cAliasQry)->(!Eof())
				//-- Analisa a faixa para obter o valor.
				nFaixa := 0
				lRet   := .F.
				If cFaixa == StrZero( 1, nLenTpFai )		//-- Peso
					If	lPesoReal									//-- Calculo pelo peso real
						nFaixa := (cAliasQry)->DT1_VALATE				//-- Pegar a faixa peso
					Else												//-- Calculo pelo peso cubado
						nFaixa := (cAliasQry)->DT1_FATPES				//-- Pegar a faixa fator peso
					EndIf
				Else
					nFaixa := (cAliasQry)->DT1_VALATE
				EndIf
				If	nBaseCal <= nFaixa
					//-- Componente de frete que determina o peso cobrado
					If	cCodPas $ cPesCob
						//--Quando e chamado pelo excedente, o peso cobrado
						//--e o valor da primeira faixa mais o excedente
						If nTpBase == 2 //--Base de Calculo pelo Excedente
							nPesoCob += nBaseCal
						Else
							nPesoCob := nBaseCal
						EndIf
					EndIf

					nPerAju	:= 0
					nInterv	:= (cAliasQry)->DT1_INTERV
					nRet	:= (cAliasQry)->DT1_VALOR
					lRet    := .T.

					//-- Qdo o componente possuir sub-faixas, atualiza o peso cobrado, percentual e intervalo.
					If nBaseCalFx2 > 0
						cSeek  := xFilial('DW1') + (cAliasQry)->DT1_TABFRE + (cAliasQry)->DT1_TIPTAB + (cAliasQry)->DT1_CDRORI + (cAliasQry)->DT1_CDRDES + (cAliasQry)->DT1_CODPRO + (cAliasQry)->DT1_CODPAS + (cAliasQry)->DT1_ITEM
						bWhile := { || DW1->( !Eof() .And. DW1->DW1_FILIAL + DW1->DW1_TABFRE + DW1->DW1_TIPTAB + DW1->DW1_CDRORI + DW1->DW1_CDRDES + DW1->DW1_CODPRO + DW1->DW1_CODPAS + DW1->DW1_ITEDT1 == cSeek ) }
						TMSFx2Aju("DW1",cSeek,bWhile,0,@nInterv,lPesoReal,nBaseCalFx2,cFaixa2,nLenTpFai,cPesCob,@nPesoCob,,@nRet)
					EndIf

					DT1->(dbGoTo((cAliasQry)->RECNO_DT1))
					cRecDT1 := DT1->DT1_ITEM
					Exit
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo

			If nRet == 0  .And. !lRet
				If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '09' } ) == 0 .And. cComObr == StrZero(1,Len(DVE->DVE_COMOBR))
					AAdd( aMsgErr, { STR0038 + AllTrim(Str(nBaseCal)) + STR0039 + AllTrim( DT3->DT3_DESCRI ) + STR0040 + cTabFre + ' ' + cTipTab + ' ' + cSeqTab + STR0041 + cCdrOri + STR0042 + cCdrDes + STR0037 + cCodPro, '09', 'TMSA010()' } ) //"Base de calculo "###" maior que as faixas do componente "###"  (DT1).  Tabela: "###" Reg.Ori: "###" Reg.Des: "###"Produto :"
				EndIf
			EndIf
		Else
			lTarifa := ( ! Empty( cTabTar ) )

			If lMsgErr .And. ! lTarifa .And. cComObr == StrZero(1,Len(DVE->DVE_COMOBR)) .And. Ascan( aMsgErr, { |x| x[ 2 ] == '13' } ) == 0
				AAdd( aMsgErr, { STR0043 + cTabFre + '/' + cTipTab + '/' + STR0041 + cCdrOri + STR0042 + cCdrDes + STR0037 + cCodPro + STR0044 + AllTrim( DT3->DT3_DESCRI ), '13', 'TMSA010()' } ) //"Item da tabela de frete nao encontrado  (DT1).  Tabela: "###" Reg.Ori: "###" Reg.Des: "###"Produto :"###" Compon: "
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	ElseIf !Empty(DT3->DT3_FAIXA2)
		DYA->(dbSetOrder(1))
		cSeek  := xFilial('DYG') + cTabFre + cTipTab + cCodPas + cCliDes + cLojDes
		bWhile := { || DYG->( !Eof() .And. DYG->DYG_FILIAL + DYG->DYG_TABFRE + DYG->DYG_TIPTAB + DYG->DYG_CODPAS + DYG->DYG_CLIDES  + DYG->DYG_LOJDES == cSeek ) }
		TMSFx2Aju("DYG",cSeek,bWhile,0,@nInterv,lPesoReal,nBaseCalFx2,cFaixa2,nLenTpFai,cPesCob,@nPesoCob,,@nRet)
		If nRet == 0
			If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '09' } ) == 0 .And. cComObr == StrZero(1,Len(DVE->DVE_COMOBR))
				AAdd( aMsgErr, { STR0038 + AllTrim(Str(nBaseCal)) + STR0039 + AllTrim( DT3->DT3_DESCRI ) + STR0233 + cTabFre + ' ' + cTipTab + ' ' + cSeqTab + STR0234 + cCliDes + STR0235 + cLojDes, '09', 'TMSA010()' } ) //"Base de calculo "###" maior que as faixas do componente "###"  (DYG).  Tabela: "###" Cliente:"###" Loja: "###"
			EndIf
		EndIf
	EndIf
//-- Ajuste da Tabela
Else

	If _oVlFxDVD == Nil

		_oVlFxDVD := FWPreparedStatement():New()
		cQuery := "   SELECT DVD_VALATE, DVD_FATPES, DVD_VALATE, DVD_PERAJU, DVD_INTERV, DVD_RGOTAB, DVD_RGDTAB, DVD_PRDTAB, DVD_TABFRE, DVD_TIPTAB, DVD_CDRORI, DVD_CDRDES, DVD_CODCLI, DVD_LOJCLI, DVD_SEQTAB, DVD_CODPRO, DVD_SERVIC, DVD_CODPAS, DVD_ITEM, R_E_C_N_O_ RECNO_DVD "
		cQuery += ",DVD_CODNEG "
		cQuery += "     FROM " + RetSqlName("DVD")
		cQuery += "    WHERE DVD_FILIAL = ? "
		cQuery += "      AND DVD_TABFRE = ? "
		cQuery += "      AND DVD_TIPTAB = ? "
		cQuery += "      AND DVD_CDRORI = ? "
		cQuery += "      AND DVD_CDRDES = ? "
		cQuery += "      AND DVD_CODCLI = ? "
		cQuery += "      AND DVD_LOJCLI = ? "
		cQuery += "      AND DVD_SEQTAB = ? "
		cQuery += "      AND DVD_CODPRO = ? "
		cQuery += "      AND DVD_CODNEG = ? "
		cQuery += "      AND DVD_SERVIC = ? "
		cQuery += "      AND DVD_CODPAS	= ? "
		cQuery += "      AND D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY " + SqlOrder(DVD->(IndexKey()))
		cQuery := ChangeQuery(cQuery)

		_oVlFxDVD:SetQuery(cQuery)
	EndIf

	_oVlFxDVD:SetString(1,xFilial('DVD')  )
	_oVlFxDVD:SetString(2,cTabFre)
	_oVlFxDVD:SetString(3,cTipTab )
	_oVlFxDVD:SetString(4,cCdrOri )
	_oVlFxDVD:SetString(5,cCdrDes )
	_oVlFxDVD:SetString(6,cCodCli )
	_oVlFxDVD:SetString(7,cLojCli )
	_oVlFxDVD:SetString(8,cSeqTab )
	_oVlFxDVD:SetString(9,cCodPro )
	_oVlFxDVD:SetString(10,cCodNeg )
	_oVlFxDVD:SetString(11,cServic )
	_oVlFxDVD:SetString(12,cCodPas )

	DVD->( DbSetOrder( 1 ) )
	cAliasQry := GetNextAlias()

	cQuery	:= _oVlFxDVD:GetFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	If (cAliasQry)->(!Eof())

		While (cAliasQry)->(!Eof())
			//-- Analisa a faixa para obter o valor.
			nFaixa	:= 0
			lRet    := .F.
			If	cFaixa == StrZero( 1, nLenTpFai )		//-- Peso
				If	lPesoReal							//-- Calculo pelo peso real
					nFaixa := (cAliasQry)->DVD_VALATE	//-- Pegar a faixa peso
				Else									//-- Calculo pelo peso cubado
					nFaixa := (cAliasQry)->DVD_FATPES	//-- Pegar a faixa fator peso
				EndIf
			Else
				nFaixa := (cAliasQry)->DVD_VALATE
			EndIf
			If	nBaseCal <= nFaixa
				//-- Componente de frete que determina o peso cobrado
				If	cCodPas $ cPesCob
					//--Quando e chamado pelo excedente, o peso cobrado
					//--e o valor da primeira faixa mais o excedente
					If nTpBase == 2 //--Base de Calculo pelo Excedente
						nPesoCob += nBaseCal
					Else
						nPesoCob := nBaseCal
					EndIf
				EndIf

				//-- Se for um ajuste, guardar percentual de ajuste, intervalo e item do ajuste.
				//-- Posicionar na tabela mae, utilizando o item para obter o valor.
				nPerAju	 := (cAliasQry)->DVD_PERAJU
				nInterv	 := (cAliasQry)->DVD_INTERV
				//-- Informacoes necessarias para posicionar a tabela de frete
				cRgOTab	 := (cAliasQry)->DVD_RGOTAB
				cRgDTab	 := (cAliasQry)->DVD_RGDTAB
				cPrdTab	 := (cAliasQry)->DVD_PRDTAB
				cItemDVD := (cAliasQry)->DVD_ITEM

				//-- Qdo o componente possuir sub-faixas, atualiza o peso cobrado, percentual e intervalo.
				If nBaseCalFx2 > 0
					DW2->(DbSetOrder(2))
					cSeek  := xFilial('DW2') + (cAliasQry)->DVD_TABFRE + (cAliasQry)->DVD_TIPTAB + (cAliasQry)->DVD_CDRORI + (cAliasQry)->DVD_CDRDES + (cAliasQry)->DVD_CODCLI + (cAliasQry)->DVD_LOJCLI + (cAliasQry)->DVD_SEQTAB + (cAliasQry)->DVD_CODPRO + (cAliasQry)->DVD_CODNEG + (cAliasQry)->DVD_SERVIC + (cAliasQry)->DVD_CODPAS + (cAliasQry)->DVD_ITEM
					bWhile := { || DW2->( !Eof() .And. DW2->DW2_FILIAL + DW2->DW2_TABFRE + DW2->DW2_TIPTAB + DW2->DW2_CDRORI + DW2->DW2_CDRDES + DW2->DW2_CODCLI + DW2->DW2_LOJCLI + DW2->DW2_SEQTAB + DW2->DW2_CODPRO + DW2->DW2_CODNEG + DW2->DW2_SERVIC + DW2->DW2_CODPAS + DW2->DW2_ITEDVD == cSeek ) }
					TMSFx2Aju("DW2",cSeek,bWhile,@nPerAju,@nInterv,lPesoReal,nBaseCalFx2,cFaixa2,nLenTpFai,cPesCob,@nPesoCob,@cItemDW2)
				EndIf

				//-- Posiciona na tabela de frete
				DT0->( DbSetOrder( 1 ) )
				If	DT0->( MsSeek( xFilial('DT0') + cTabFre + cTipTab + cRgOTab + cRgDTab + cPrdTab ) )

					//-- Posiciona no item da tabela de frete
					DT1->( DbSetOrder( 1 ) )
					If	DT1->( MsSeek( xFilial('DT1') + cTabFre + cTipTab + cRgOTab + cRgDTab + cPrdTab + cCodPas + cItemDVD ) )
						//-- Busca o valor do componente nas sub-faixas.
						If nBaseCalFx2 > 0
							DW1->(DbSetOrder(1))
							If DW1->(MsSeek(xFilial('DW1')+cTabFre+cTipTab+cRgOTab+cRgDTab+cPrdTab+cCodPas+DT1->DT1_ITEM+cItemDW2))
								nRet := DW1->DW1_VALOR
							EndIf
						Else
							nRet := DT1->DT1_VALOR
						EndIf
						lRet := .T.
					EndIf

					If nRet == 0  .And. !lRet
						//-- Posiciona no item da tabela de tarifa
						DTG->( DbSetOrder( 1 ) )	//-- DTG_FILIAL + DTG_TABFRE + DTG_TIPTAB + DTG_TABTAR + DTG_CODPAS + DTG_ITEM
						If	DTG->( MsSeek( xFilial('DTG') + cTabFre + cTipTab + DT0->DT0_TABTAR + cCodPas + cItemDVD ) )
							//-- Busca o valor do componente nas sub-faixas.
							If nBaseCalFx2 > 0
								DW0->(DbSetOrder(1))
								If DW0->(MsSeek(xFilial('DW0')+cTabFre+cTipTab+DT0->DT0_TABTAR+cCodPas+DTG->DTG_ITEM+cItemDW2))
									nRet := DW0->DW0_VALOR
								Else
									lExistMsg := .T.
									If lMsgErr .And. cComObr == StrZero(1,Len(DVE->DVE_COMOBR)) .And. Ascan( aMsgErr, { |x| x[ 2 ] == '11' } ) == 0
										AAdd( aMsgErr, { STR0045 + cTabFre + '/' + cTipTab + STR0046 + DT0->DT0_TABTAR +  '/' + STR0041 + cRgOTab + STR0042 + cRgDTab + STR0047 + cPrdTab + STR0048 + AllTrim( DT3->DT3_DESCRI ), '16', 'TMSA010()' } ) //"Item nao encontrado na Tab.Frete/Tab.Tarifa. Tab.Frete : "###" - Tab.Tarifa : "###" Reg.Ori: "###" Reg.Des: "###" Prod.: "###"Campo: "
									EndIf
								EndIf
							Else
								nRet := DTG->DTG_VALOR
							EndIf
							lRet := .T.
						Else
							lExistMsg := .T.
							If lMsgErr .And. cComObr == StrZero(1,Len(DVE->DVE_COMOBR)) .And. Ascan( aMsgErr, { |x| x[ 2 ] == '11' } ) == 0
								AAdd( aMsgErr, { STR0045 + cTabFre + '/' + cTipTab + STR0046 + DT0->DT0_TABTAR +  '/' + STR0041 + cRgOTab + STR0042 + cRgDTab + STR0047 + cPrdTab + STR0044 + AllTrim( DT3->DT3_DESCRI ), '16', 'TMSA010()' } ) //"Item nao encontrado na Tab.Frete/Tab.Tarifa. Tab.Frete : "###" - Tab.Tarifa : "###" Reg.Ori: "###" Reg.Des: "###" Prod.: "###" Compon: "
							EndIf
						EndIf
					EndIf
				Else
					lExistMsg := .T.
					If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '15' } ) == 0
						AAdd( aMsgErr, { STR0049 + cTabFre + '/' + cTipTab + '/' + STR0041 + cRgOTab + STR0042 + cRgDTab + STR0047 + cPrdTab, '15', 'TMSA010()' } ) //"Tabela de frete não encontrada para cálculo do ajuste.  Tabela: "###" Reg.Ori: "###" Reg.Des: "###" Prod.: "
					EndIf
				EndIf

				DVD->(dbGoTo((cAliasQry)->RECNO_DVD))
				Exit
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo

		(cAliasQry)->(DbCloseArea())

		If nRet == 0 .And. !lExistMsg .And. !lRet
			If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '14' } ) == 0
				AAdd( aMsgErr, { STR0038 + AllTrim(Str(nBaseCal)) + STR0039 + AllTrim( DT3->DT3_DESCRI ) + STR0050 + cTabFre + ' ' + cTipTab + ' ' + cSeqTab + STR0041 + cCdrOri + STR0042 + cCdrDes + STR0051 + cCodCli + '/' + cLojCli + STR0037 + cCodPro + STR0052 + cServic + STR0285 + cCodNeg, '14', 'TMSA011()' } ) //"Base de calculo "###" maior que as faixas do componente "###"  (DVD).  Tabela: "###" Reg.Ori: "###" Reg.Des: "###" Cliente: "###"Produto :"###" Servico: "###" Negociacao:"
			EndIf
		ElseIf nPerAju == 0
			nRet := 0
		EndIf
	Else
		If lMsgErr .And. cComObr == StrZero(1,Len(DVE->DVE_COMOBR)) .And. Ascan( aMsgErr, { |x| x[ 2 ] == '20' } ) == 0
			AAdd( aMsgErr, { STR0053 + cTabFre + '/' + cTipTab + '/' + STR0041 + cCdrOri + STR0042 + cCdrDes + STR0037 + cCodPro + STR0044 + AllTrim( DT3->DT3_DESCRI ), '20', 'TMSA011()' } ) //"Item do ajuste nao encontrado. Tabela: "###" Reg.Ori: "###" Reg.Des: "###"Produto :"###" Compon: "
		EndIf
	EndIf
EndIf

//-- Tabela de Tarifa (So' verifica se for Tabela Cheia)
If lTarifa
	//-- Posiciona na tabela de tarifa
	DTF->( DbSetOrder( 1 ) )										//-- DTF_FILIAL + DTF_TABFRE + DTF_TIPTAB + DTF_TABTAR
	If	DTF->( MsSeek( xFilial('DTF') + cTabFre + cTipTab + cTabTar ) )
		//-- Posiciona no item da tabela de tarifa
		If _oVlFxDTG == Nil
			_oVlFxDTG	:= FwPreparedStatement():New()

			cQuery := "   SELECT DTG_VALATE, DTG_FATPES, DTG_VALATE, DTG_INTERV, DTG_VALOR, DTG_TABFRE, DTG_TIPTAB, DTG_TABTAR, DTG_CODPAS, DTG_ITEM, R_E_C_N_O_ RECNO_DTG "
			cQuery += "     FROM " + RetSqlName("DTG")
			cQuery += "    WHERE DTG_FILIAL = ? "
			cQuery += "      AND DTG_TABFRE = ? "
			cQuery += "      AND DTG_TIPTAB = ? "
			cQuery += "      AND DTG_TABTAR = ? "
			cQuery += "      AND DTG_CODPAS = ? "
			cQuery += "      AND D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY " + SqlOrder(DTG->(IndexKey()))
			cQuery := ChangeQuery(cQuery)

			_oVlFxDTG:SetQuery(cQuery)

		EndIf

		_oVlFxDTG:SetString(1,xFilial('DTG') )
		_oVlFxDTG:SetString(2,cTabFre)
		_oVlFxDTG:SetString(3,cTipTab)
		_oVlFxDTG:SetString(4,cTabTar)
		_oVlFxDTG:SetString(5,cCodPas)

		//-- Posiciona no item da tabela de tarifa
		DTG->( DbSetOrder( 1 ) ) //-- DTG_FILIAL + DTG_TABFRE + DTG_TIPTAB + DTG_TABTAR + DTG_CODPAS + DTG_ITEM

		cAliasQry 	:= GetNextAlias()
		cQuery		:= _oVlFxDTG:GetFixQuery()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

		If (cAliasQry)->(!Eof())

			While (cAliasQry)->(!Eof())
				//-- Analisa a faixa para obter o valor.
				nFaixa := 0
				If	cFaixa == StrZero( 1, nLenTpFai )		//-- Peso
					If	lPesoReal									//-- Calculo pelo peso real
						nFaixa := (cAliasQry)->DTG_VALATE				//-- Pegar a faixa peso
					Else												//-- Calculo pelo peso cubado
						nFaixa := (cAliasQry)->DTG_FATPES				//-- Pegar a faixa fator peso
					EndIf
				Else
					nFaixa := (cAliasQry)->DTG_VALATE
				EndIf

				If	nBaseCal <= nFaixa
					//-- Componente de frete que determina o peso cobrado.
					If	cCodPas $ cPesCob
						//--Quando e chamado pelo excedente, o peso cobrado
						//--e o valor da primeira faixa mais o excedente
						If nTpBase == 2 //--Base de Calculo pelo Excedente
							nPesoCob += nBaseCal
						Else
							nPesoCob := nBaseCal
						EndIf
					EndIf

					nPerAju	:= 0
					nInterv	:= (cAliasQry)->DTG_INTERV
					nRet	:= (cAliasQry)->DTG_VALOR

					//-- Qdo o componente possuir sub-faixas, atualiza o peso cobrado, percentual e intervalo.
					If nBaseCalFx2 > 0
						cSeek  := xFilial('DW0') + (cAliasQry)->DTG_TABFRE + (cAliasQry)->DTG_TIPTAB + (cAliasQry)->DTG_TABTAR + (cAliasQry)->DTG_CODPAS + (cAliasQry)->DTG_ITEM
						bWhile := { || DW0->( !Eof() .And. DW0->DW0_FILIAL + DW0->DW0_TABFRE + DW0->DW0_TIPTAB + DW0->DW0_TABTAR + DW0->DW0_CODPAS + DW0->DW0_ITEDTG == cSeek ) }
						TMSFx2Aju("DW0",cSeek,bWhile,0,@nInterv,lPesoReal,nBaseCalFx2,cFaixa2,nLenTpFai,cPesCob,@nPesoCob,,@nRet)
					EndIf

					DTG->(dbGoTo((cAliasQry)->RECNO_DTG))
					cRecDTG := DTG->DTG_ITEM
					Exit
				EndIf

				(cAliasQry)->(DbSkip())
			EndDo

			(cAliasQry)->(DbCloseArea())

			If nRet == 0
				If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '10' } ) == 0
					AAdd( aMsgErr, { STR0038 + AllTrim(Str(nBaseCal)) + STR0039 + AllTrim( DT3->DT3_DESCRI ) + STR0054 + cTabFre + ' ' + cTipTab + STR0046 + cTabTar, '10', 'TMSA080()' } ) //"Base de calculo "###" maior que as faixas do componente "###"  (DTG).  Tab.Frete: "###" - Tab.Tarifa : "
				EndIf
			EndIf
		Else
			If	lMsgErr .And. cComObr == StrZero(1,Len(DVE->DVE_COMOBR)) .And. Ascan( aMsgErr, { |x| x[ 2 ] == '11' } ) == 0
				AAdd( aMsgErr, { STR0055 + cTabFre + ' ' + cTipTab + STR0046 + cTabTar + STR0056 + AllTrim( DT3->DT3_DESCRI ), '11', 'TMSA080()' } ) //"Item da tarifa nao encontrado  (DTG).  Tab.Frete: "###" - Tab.Tarifa : "###" Componente: "
			EndIf
		EndIf
	Else
		If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '12' } ) == 0
			AAdd( aMsgErr, { STR0057 + cTabTar + STR0058 + cTabFre + STR0059 + cTipTab + '. (DTF)', '12', 'TMSA080()' } ) //"Nao encontrou a tabela de tarifa "###" Tab.Frete "###" Tipo Tab. "
		EndIf
	EndIf
EndIf

//-- Atualiza a base de calculo do componente.
nBaseCal := nBaseSobre

//-- Se houve ajuste aplicar o percentual
If	nPerAju > 0
	nRet := nRet * ( nPerAju / 100 )
	//-- Calcula pelo percentual ou pelo inteiro
	nRet := TmsVlCalc( cFracao, (nBaseCal - nExcMin), nInterv, nRet, 0 )
Else
	//-- Calcula pelo percentual ou pelo inteiro e aplica percentual de cobranca
	nRet := TmsVlCalc( cFracao, (nBaseCal - nExcMin), nInterv, nRet, nPerCob )
EndIf

AAdd(aFaixaTab, {cCodPas,nFaixa,nBaseCal,nRet,nInterv} )

RestArea(aAreaDT1)
RestArea(aAreaDVD)
RestArea(aAreaDTG)
Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsVlCalc³ Autor ³ Alex Egydio           ³ Data ³09.12.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Regras para o calculo do componente de frete, que se       ³±±
±±³          ³ aplicam para a tabela de frete                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Fracao 1 = Percentual / 2 = Inteiro                ³±±
±±³          ³ ExpN1 = Valor base para calculo                            ³±±
±±³          ³ ExpN2 = Intervalo                                          ³±±
±±³          ³ ExpN3 = Valor obtido na tabela                             ³±±
±±³          ³ ExpN4 = Percentual de cobranca                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Valor do componente                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsVlCalc( cFracao, nBaseCal, nInterv, nValor, nPerCob )

Local nInteiro	:= 0
Local nResto	:= 0
Local nRet		:= 0

//-- Sera cobrado o valor a cada intervalo
If	nInterv > 0
	//-- Calcula pelo percentual
	If	cFracao == StrZero(1,Len(DT3->DT3_FRACAO))

		nRet := ( nBaseCal * (nValor / nInterv ) )

	//-- Calcula pelo inteiro
	Else
		nResto	:= 0
		nInteiro := Int( nBaseCal / nInterv )
		If	Empty( nInteiro )
			nInteiro := 1
		Else
			nResto := Mod( nBaseCal, nInterv )
			If nResto > 0
				nResto := 1
			EndIf
		EndIf

		nRet := ( ( nInteiro + nResto ) * nValor )

	EndIf
Else

	nRet := nValor

EndIf

//-- Aplica percentual de cobranca
If	nPerCob > 0
	nRet := nRet * ( nPerCob / 100 )
EndIf


Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSDestCal³ Autor ³ Alex Egydio           ³ Data ³12.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Destino de Calculo                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSDestCal()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do cliente                                  ³±±
±±³          ³ ExpC2 = Loja   do cliente                                  ³±±
±±³          ³ ExpC3 = Codigo da regiao de destino                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Codigo da regiao de destino de calculo                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSDestCal( cCodCli, cLojCli, cCdrDes )

Local aAreaAnt	:= GetArea()
Local aAreaDTH	:= DTH->( GetArea() )
Local cCliGen	:= GetMV('MV_CLIGEN')
Local cRet		:= ''

DTH->( DbSetOrder( 1 ) )
//-- Destino de calculo definido para um cliente e regiao de destino.
If DTH->( MsSeek( xFilial('DTH') + cCodCli + cLojCli + cCdrDes, .F. ) ) .And. ;
		DTH->DTH_ATIVO == StrZero(1, Len(DTH->DTH_ATIVO))
	cRet := DTH->DTH_CDRCAL
Else
	//-- Destino de calculo definido para uma regiao de destino.
	If DTH->( MsSeek( xFilial('DTH') + cCliGen + cCdrDes, .F. ) ) .And. ;
			DTH->DTH_ATIVO == StrZero(1, Len(DTH->DTH_ATIVO))
		cRet := DTH->DTH_CDRCAL
	EndIf
EndIf

If IsInCallStack('TMSAF76') .And. !Empty(M->DTC_SQEDES) .And. !Empty(M->DTC_CDRCAL)
	cCdrDes	:= M->DTC_CDRCAL
EndIf 

RestArea( aAreaDTH )
RestArea( aAreaAnt )

Return( Iif( Empty( cRet ) , cCdrDes, cRet ) )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsTabela³ Autor ³ Alex Egydio           ³ Data ³07.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Localiza uma tabela de frete valida.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsTabela()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor indicando onde ocorreu erros no calculo      ³±±
±±³          ³ ExpC1 = Codigo do tabela                                   ³±±
±±³          ³ ExpC2 = Tipo da tabela                                     ³±±
±±³          ³ ExpC3 = Sequencia da tabela                                ³±±
±±³          ³ ExpC4 = Regiao origem                                      ³±±
±±³          ³ ExpC5 = Regiao destino                                     ³±±
±±³          ³ ExpC6 = Cliente                                            ³±±
±±³          ³ ExpC7 = Loja                                               ³±±
±±³          ³ ExpC8 = Produto                                            ³±±
±±³          ³ ExpC9 = Servico                                            ³±±
±±³          ³ ExpCA = Tabela de tarifa                                   ³±±
±±³          ³ ExpCB = Indica se o componente se refere a taxa            ³±±
±±³          ³ ExpCC = Componente qd chamado do ajuste (TMSA011)          ³±±
±±³          ³ ExpCD = Pesquisa taxa                                      ³±±
±±³          ³ ExpCE = Verifica se Existe Ajuste para o componente        ³±±
±±³          ³ ExpCF = Regiao Origem da Tabela Mae                        ³±±
±±³          ³ ExpCG = Regiao Destino da Tabela Mae                       ³±±
±±³          ³ ExpCH = Produto da Tabela Mae                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Se encontrou uma tabela                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTabela( aMsgErr, cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cTabTar, cTaxa, cCodPas, cPsqTxa, lExistAju, cRgOTab, cRgDTab, cPrdTab, cCatTab, cTipFai, cCodNeg)

Static lTMSExp    	:= TMSExp()
Static lTMSAJST   	:= SuperGetMV("MV_TMSAJST",.F.,.F.) //-- Verifica se existe ajuste para todos componentes

Local aInfoAnt    	:= {}
Local aRegiao     	:= {}
Local aAuxDVC	  	:= {}
Local lAjuste     	:= .F.
Local lPesqProd   	:= .T.
Local lRet        	:= .T.
Local nCntFor     	:= 0
Local cQuery      	:= ""
Local cAliasQry   	:= ""
Local aArea		  	:= GetArea()
Local cCodNegVaz  	:= Space(Len(DVC->DVC_CODNEG))
Local aRetPE      	:= {}
Local lHerdValor  	:= .F.
Local nPrioridade  	:= 0
Local lLastSeqTb	:= .T. 	//-- Busca ultima sequencia de tabela?

Default aMsgErr   := {}
Default cCodCli   := Space(Len(DVC->DVC_CODCLI))
Default cLojCli   := Space(Len(DVC->DVC_LOJCLI))
Default cCodPas   := ""
Default cTaxa     := StrZero(2,Len(DT3->DT3_TAXA))
Default cPsqTxa   := StrZero(2,Len(DT3->DT3_PSQTXA))
Default lExistAju := .F.
Default cRgOTab   := ""
Default cRgDTab   := ""
Default cPrdTab   := ""
Default cCatTab   := ""
Default cTipFai   := ""
Default cCodNeg   := ""

lHerdValor  := cTipFai == StrZero(16, Len(DT3->DT3_FAIXA))
aInfoAnt 	:= {cSeqTab,cCodPro,cServic,cTabFre,cTipTab}  //guarda os valores originais na chamada da funcao

//-- Regra para encontrar uma tabela :
//-- Tabela mae: DT0 com produto preenchido ou produto em branco
//-- Ajustes   : DVC com cCodCli / cLojCli preenchido e cSeqTab diferente de zero
lAjuste := ! Empty( cCodCli )
If lTMSTab
	aRetPE := ExecBlock("TMSTAB",.F.,.F.,{cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodNeg, cServic})
	If ValType(aRetPE) == "A"
		cCdrOri := aRetPE[1]
		cCdrDes := aRetPE[2]
		If Len(aRetPE) == 5
			cTabFre 	:= aRetPE[3]
			cTipTab 	:= aRetPE[4]
			cSeqTab 	:= aRetPE[5]
			lLastSeqTb	:= .F.
		EndIf
	EndIf
EndIf

//-- Procura ajuste
If lAjuste

	If	lPrcProd ==  Nil
		lPrcProd := GetMV('MV_PRCPROD',,.T.) //-- Calcula Preco do Frete por Produto ?
	EndIf

	//-- Localiza tabela de frete
	If Empty(cCatTab)
		cCatTab := My_Posicione('DTL',1,xFilial('DTL') + cTabFre + cTipTab,'DTL_CATTAB')
	EndIf
	//-- Frete a pagar nao tem ajuste
	If	cCatTab == StrZero(2,Len(DTL->DTL_CATTAB))
		Return( .F. )
	EndIf

	// Adiciona as Regioes no Vetor aRegiao
	TMSAddReg(@aRegiao, cCdrOri, cCdrDes, cTaxa, cPsqTxa)
	DT0->(dbSetOrder(1)) //DT0_FILIAL+DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+DT0_CODPRO
	DVC->(dbSetOrder(7)) //DVC_FILIAL+DVC_CODCLI+DVC_LOJCLI+DVC_TABFRE+DVC_TIPTAB+DVC_CDRORI+DVC_CDRDES+DVC_CODPRO+DVC_CODNEG+DVC_SERVIC+DVC_SEQTAB se for indice 7
										 //DVC_FILIAL+DVC_CODCLI+DVC_LOJCLI+DVC_TABFRE+DVC_TIPTAB+DVC_CDRORI+DVC_CDRDES+DVC_CODPRO+DVC_SERVIC+DVC_SEQTAB se for indice 2

	For nCntFor := 1 To Len( aRegiao )
		lRet	:= .F.

		If	!Empty( aRegiao[ nCntFor, 1 ] ) .And. !Empty( aRegiao[ nCntFor, 2 ] )
			cCodPro := aInfoAnt[ 2 ]
			If lPrcprod
				//-- Se encontrou tabela de precos para este produto...
				lPesqProd := !DT0->(MsSeek(xFilial('DT0')+ cTabFre + cTipTab + aRegiao[ nCntFor, 1 ] + aRegiao[ nCntFor, 2 ] + cCodPro ))
			EndIf

			If _oTabMae == Nil

				_oTabMae	:= FWPreparedStatement():New()

				cQuery	:= " SELECT DVC_CODPRO , DVC_CODNEG, DVC_SERVIC , R_E_C_N_O_ DVCRECNO  "
				cQuery	+= " FROM " + RetSqlName("DVC") + " DVC "
				cQuery 	+= "    WHERE DVC_FILIAL = ? "
				cQuery 	+= "      AND DVC_CODCLI = ? "
				cQuery 	+= "      AND DVC_LOJCLI = ? "
				cQuery 	+= "      AND DVC_TABFRE = ? "
				cQuery 	+= "      AND DVC_TIPTAB = ? "
				cQuery 	+= "      AND DVC_CDRORI = ? "
				cQuery 	+= "      AND DVC_CDRDES = ? "
				cQuery 	+= "      AND ( DVC_CODPRO = ? OR  DVC_CODPRO = ? ) "
				cQuery	+= "      AND ( DVC_CODNEG = ? OR DVC_CODNEG  = ? ) "
				cQuery	+= "	  AND ( DVC_SERVIC = ? OR DVC_SERVIC  = ? ) "
				cQuery 	+= "      AND D_E_L_E_T_ = ' ' "
				cQuery 	+= " ORDER BY DVC_SERVIC DESC , "
				cQuery	+= " DVC_CODPRO DESC ,"
				cQuery	+= " DVC_CODNEG DESC  "

				cQuery 	:= ChangeQuery(cQuery)
				_oTabMae:SetQuery(cQuery)
			EndIf

			_oTabMae:SetString(1,xFilial('DVC'))
			_oTabMae:SetString(2,cCodCli	)
			_oTabMae:SetString(3,cLojCli	)
			_oTabMae:SetString(4,cTabFre	)
			_oTabMae:SetString(5,cTipTab	)
			_oTabMae:SetString(6,aRegiao[ nCntFor, 1 ])
			_oTabMae:SetString(7,aRegiao[ nCntFor, 2 ])
			_oTabMae:SetString(8,cCodPro	)
			_oTabMae:SetString(9,Iif(lPesqProd,Space(Len(DVC->DVC_CODPRO)),cCodPro) )
			_oTabMae:SetString(10,cCodNeg	)
			_oTabMae:SetString(11,cCodNegVaz)
			_oTabMae:SetString(12,cServic	)
			_oTabMae:SetString(13,Space(Len(DVC->DVC_SERVIC)))

			cQuery		:= _oTabMae:getFixQuery()
			cAliasQry	:= GetNextAlias()
			lRet		:= .F.

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			While (cAliasQry)->(!Eof())

				/*------------------------------------------------------------------------------------
				//-- ORDEM DE PRIORIDADES DA ANÁLISE COMBINATÓRIA
				//------------------------------------------------------------------------------------
				//-- 1 cCodPro 	+ cCodNeg 		+ cServic 	= 111
				//-- 2 cCodPro 	+ Empty 		+ cServic 	= 101
				//-- 3 Empty 	+ cCodNeg 		+ cServic 	= 011
				//-- 4 Empty 	+ Empty 		+ cServic 	= 001
				//-- 5 cCodPro 	+ cCodNeg 		+ Empty		= 110
				//-- 6 cCodPro 	+ Empty 		+ Empty 	= 100
				//-- 7 Empty 	+ Empty 		+ Empty 	= 000
				//-------------------------------------------------------------------------------------
				--------------------------------------------------------------------------------------*/
				nPrioridade		:= 0

				If !Empty((cAliasQry)->DVC_SERVIC)
					If !Empty((cAliasQry)->DVC_CODPRO ) .And.  !Empty( (cAliasQry)->DVC_CODNEG )
						nPrioridade	:= 1
					ElseIf !Empty((cAliasQry)->DVC_CODPRO ) .And. Empty((cAliasQry)->DVC_CODNEG)
						nPrioridade	:= 2
					ElseIf Empty((cAliasQry)->DVC_CODPRO ) .And. !Empty( (cAliasQry)->DVC_CODNEG )
						nPrioridade	:= 3
					Else
						nPrioridade := 4
					EndIf
				Else
					If !Empty((cAliasQry)->DVC_CODPRO ) .And.  !Empty( (cAliasQry)->DVC_CODNEG )
						nPrioridade	:= 5
					ElseIf !Empty((cAliasQry)->DVC_CODPRO ) .And. Empty((cAliasQry)->DVC_CODNEG)
						nPrioridade	:= 6
					ElseIf Empty((cAliasQry)->DVC_CODPRO ) .And. Empty((cAliasQry)->DVC_CODNEG)
						nPrioridade	:= 7
					EndIf
				EndIf

				If nPrioridade > 0
					Aadd( aAuxDVC , { nPrioridade , (cAliasQry)->DVCRECNO } )
				EndIf

				(cAliasQry)->(dbSkip())

			EndDo
			(cAliasQry)->(DbCloseArea())

			If Len(aAuxDVC) > 0
				lRet	:= .T.
				aSort(aAuxDVC,,,{|x,y| x[1] < y[1] })
				DVC->( DbGoTo( aAuxDVC[1,2] ) )
			EndIf

			If lRet .And. cTipFai == StrZero(9,Len(DT3->DT3_FAIXA)) .And. (lTMSExp .Or. IsInCallStack("TMSAF76")) //-- Praca de Pedagio
				Exit
			EndIf

			If lRet

				lRet := GetTmsTab( cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cTabTar, cTaxa, cCodPas, cPsqTxa, lExistAju, cRgOTab, cRgDTab, cPrdTab, cCodNeg)

				If !lRet
					//-- Verifica se existe ajuste para tabela
					If !lTMSAJST
						lExistAju := .T.
					EndIf

					If _oTabDVC == Nil
						_oTabDVC	:= FWPreparedStatement():New()

						cQuery := "   SELECT DVC_CODPRO, DVC_SERVIC, DVC_SEQTAB "
						CQuery += ", DVC_CODNEG "
						cQuery += "     FROM " + RetSqlName("DVC")
						cQuery += "    WHERE DVC_FILIAL = ? "
						cQuery += "      AND DVC_CODCLI = ? "
						cQuery += "      AND DVC_LOJCLI = ? "
						cQuery += "      AND DVC_TABFRE = ? "
						cQuery += "      AND DVC_TIPTAB = ? "
						cQuery += "      AND DVC_CDRORI = ? "
						cQuery += "      AND DVC_CDRDES = ? "
						cQuery += "      AND DVC_CODPRO = ? "
						cQuery += "      AND DVC_CODNEG = ? "
						cQuery += "      AND DVC_SERVIC = ? "
						cQuery += "      AND DVC_SEQTAB <> ? "
						cQuery += "      AND D_E_L_E_T_ = ' ' "
						cQuery += " ORDER BY " + SqlOrder(DVC->(IndexKey()))
						cQuery := ChangeQuery(cQuery)

						_oTabDVC:SetQuery(cQuery)

					EndIf

					_oTabDVC:SetString(1,DVC->DVC_FILIAL)
					_oTabDVC:SetString(2,DVC->DVC_CODCLI)
					_oTabDVC:SetString(3,DVC->DVC_LOJCLI)
					_oTabDVC:SetString(4,DVC->DVC_TABFRE)
					_oTabDVC:SetString(5,DVC->DVC_TIPTAB)
					_oTabDVC:SetString(6,DVC->DVC_CDRORI)
					_oTabDVC:SetString(7,DVC->DVC_CDRDES)
					_oTabDVC:SetString(8,DVC->DVC_CODPRO)
					_oTabDVC:SetString(9,DVC->DVC_CODNEG)
					_oTabDVC:SetString(10,DVC->DVC_SERVIC)
					_oTabDVC:SetString(11,Space(Len(DVC->DVC_SEQTAB)))

					//-- Tabela de Ajuste - pesquisa ultima sequencia.
					cAliasQry := GetNextAlias()

					cQuery	:= _oTabDVC:getFixQuery()

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
					While (cAliasQry)->(!Eof())
						cCodPro := (cAliasQry)->DVC_CODPRO
						cCodNeg := (cAliasQry)->DVC_CODNEG
						cServic := (cAliasQry)->DVC_SERVIC
						If lLastSeqTb
							cSeqTab := (cAliasQry)->DVC_SEQTAB
						EndIf
						(cAliasQry)->(DbSkip())
					EndDo
					(cAliasQry)->(DbCloseArea())

					//-- Itens de Tabela de Ajuste antes de verificar os componentes (padrao)
					DVD->(DbSetOrder(3))
					DVD->(lRet := MsSeek(xFilial('DVD') + cTabFre + cTipTab + aRegiao[ nCntFor, 1 ] + aRegiao[ nCntFor, 2 ] + cCodCli + cLojCli + cSeqTab + cCodPro + cCodNeg + cServic + cCodPas))
					If	lRet
						//-- Verifica se existe ajuste para todos componentes
						If	lTMSAJST
							lExistAju := .T.
						EndIf
						DT0->(dbSetOrder(1)) //DT0_FILIAL+DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+DT0_CODPRO
						DT0->(MsSeek(xFilial('DT0')+ cTabFre + cTipTab + DVD->DVD_RGOTAB + DVD->DVD_RGDTAB + DVD->DVD_PRDTAB ))

						cTabTar := DT0->DT0_TABTAR
						cCdrOri := aRegiao[ nCntFor, 1 ]
						cCdrDes := aRegiao[ nCntFor, 2 ]
						cRgOTab := DVD->DVD_RGOTAB
						cRgDTab := DVD->DVD_RGDTAB
						cPrdTab := DVD->DVD_PRDTAB

						SetTmsTab( cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cTabTar, cTaxa, cCodPas, cPsqTxa, lExistAju, cRgOTab, cRgDTab, cPrdTab, lRet, cCodNeg)
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	Next

//-- Procura tabela mae
Else
	//-- Adiciona as Regioes no Vetor aRegiao
	TMSAddReg(@aRegiao, cCdrOri, cCdrDes, cTaxa, cPsqTxa)

	DT0->(DbSetOrder(1)) //DT0_FILIAL+DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+DT0_CODPRO

	For nCntFor := 1 To Len( aRegiao )
		If	!Empty( aRegiao[ nCntFor, 1 ] ) .And. !Empty( aRegiao[ nCntFor, 2 ] )
			cCodPro := aInfoAnt[ 2 ]
			//-- Se nao encontrar tabela mae para o produto
			If	!DT0->( lRet := MsSeek(xFilial('DT0') + cTabFre + cTipTab + aRegiao[ nCntFor, 1 ] + aRegiao[ nCntFor, 2 ] + cCodPro  ) )
				//-- Pesquisa tabela mae com o produto em branco
				If	DT0->(lRet := MsSeek(xFilial('DT0') + cTabFre + cTipTab + aRegiao[ nCntFor, 1 ] + aRegiao[ nCntFor, 2 ] + Space( Len( DT0->DT0_CODPRO ) )))
					cCodPro := Space( Len( DT0->DT0_CODPRO ) )
				EndIf
			EndIf

			//-- Praca de Pedagio
			If lRet .And. cTipFai == StrZero(17,Len(DT3->DT3_FAIXA))
				Exit
			EndIf

			//-- Praca de Pedagio
			If lRet .And. cTipFai == StrZero(9,Len(DT3->DT3_FAIXA)) .And. (lTMSExp .Or. IsInCallStack("TMSAF76"))
				Exit
			EndIf

			// -- Herda Valor. Componentes Herda Valor não tem DT1, desta forma não precisa buscar os dados abaixo
			If lRet .And. lHerdValor
				Exit
			EndIf

			If lRet .And. !lHerdValor
				lRet := GetTmsTab( cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cTabTar, cTaxa, cCodPas, cPsqTxa, lExistAju, cRgOTab, cRgDTab, cPrdTab, "")

				If !lRet
					DT1->(DbSetOrder(1)) //DT1_FILIAL+DT1_TABFRE+DT1_TIPTAB+DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+DT1_CODPAS+DT1_ITEM
					DT1->(lRet := MsSeek(xFilial('DT1') + cTabFre + cTipTab + aRegiao[ nCntFor, 1 ] + aRegiao[ nCntFor, 2 ] + cCodPro + cCodPas))

					If !lRet .And. ! Empty(DT0->DT0_TABTAR)
						DTG->(DbSetOrder(1)) //DTG_FILIAL+DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS+DTG_ITEM
						DTG->(lRet := MsSeek(xFilial('DTG') + cTabFre + cTipTab + DT0->DT0_TABTAR + cCodPas))
					EndIf

					If	lRet
						//-- Obtem a tabela de tarifa
						cTabTar := DT0->DT0_TABTAR
						//-- Localizada as tabelas, atualiza a regiao origem e destino
						cCdrOri := aRegiao[ nCntFor, 1 ]
						cCdrDes := aRegiao[ nCntFor, 2 ]
						SetTmsTab( cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cTabTar, cTaxa, cCodPas, cPsqTxa, lExistAju, cRgOTab, cRgDTab, cPrdTab, lRet, "")
						Exit
					EndIf
				Else
					Exit
				EndIf
			EndIf
		EndIf
	Next
EndIf

If	!lRet  //Se variavel lRet for FALSE volta os valores originais cSeqTab/ cCodPro/ cServic
	cSeqTab := aInfoAnt[ 1 ]
	cCodPro := aInfoAnt[ 2 ]
	cServic := aInfoAnt[ 3 ]
	cTabFre := aInfoAnt[ 4 ]
	cTipTab := aInfoAnt[ 5 ]
EndIf

RestArea(aArea)
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SetTmsTab ³ Autor ³ Adalberto S.M         ³ Data ³13.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adicionar informacoes do contrato, funcao TMSContrat() ao   ³±±
±±³          ³vetor aTmsTabela                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SetTmsTab()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Cliente                                   ³±±
±±³          ³ExpC2 - Loja do Cliente                                     ³±±
±±³          ³ExpD1 - DataBase                                            ³±±
±±³          ³ExpC3 - Servico                                             ³±±
±±³          ³ExpC4 - Tipo de Frete (CIF / FOB)                           ³±±
±±³          ³ExpC5 - 1 = Considera a vigencia atual do contrato          ³±±
±±³          ³        2 = Considera a proxima vigencia do contrato        ³±±
±±³          ³ExpC6 - Tipo de Transporte                                  ³±±
±±³          ³ExpA1 - Vetor contendo todas as informacoes do Contrato.    ³±±
±±³          ³        Essas informacoes sao geradas pela funcao TMSContrat³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetTmsTab( cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cTabTar, cTaxa, cCodPas, cPsqTxa, lExistAju, cRgOTab, cRgDTab, cPrdTab, lTabela, cCodNeg)
	Default cTabFre	:= ""
	Default cTipTab	:= ""
	Default cSeqTab	:= ""
	Default cCdrOri	:= ""
	Default cCdrDes	:= ""
	Default cCodCli	:= ""
	Default cLojCli	:= ""
	Default cCodPro	:= ""
	Default cServic	:= ""
	Default cTabTar	:= ""
	Default cTaxa	:= ""
	Default cCodPas	:= ""
	Default cPsqTxa	:= ""
	Default cRgOTab	:= ""
	Default cRgDTab	:= ""
	Default cPrdTab	:= ""
	Default cCodNeg := ""

	If ValType(aTmsTabela) <> 'A'
		Static aTmsTabela := {}
	EndIf

	//////////////////////////////////////////////////////////////////
	// Manter lTabela sempre na ultima posicao do vetor aTmsTabela, //
	// para que a funcao GetTmsTab() funcione corretamente.         //
	//////////////////////////////////////////////////////////////////
	Aadd( aTmsTabela, { cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cTabTar, cTaxa, cCodPas, cPsqTxa, lExistAju, cRgOTab, cRgDTab, cPrdTab, lTabela, cCodNeg } )
Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetTmsTab ³ Autor ³ Adalberto S.M         ³ Data ³13.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Requisitar informacoes da Tab.de Frete existentes no vetor  ³±±
±±³          ³aTmsTabela. O intuito dessa rotina eh reaproveitar as in-   ³±±
±±³          ³formacoes ja processadas pela funcao TmsTabela(), sem que   ³±±
±±³          ³haja novamente uma busca na base de dados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GetTmsTab()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do tabela                                   ³±±
±±³          ³ ExpC2 = Tipo da tabela                                     ³±±
±±³          ³ ExpC3 = Sequencia da tabela                                ³±±
±±³          ³ ExpC4 = Regiao origem                                      ³±±
±±³          ³ ExpC5 = Regiao destino                                     ³±±
±±³          ³ ExpC6 = Cliente                                            ³±±
±±³          ³ ExpC7 = Loja                                               ³±±
±±³          ³ ExpC8 = Produto                                            ³±±
±±³          ³ ExpC9 = Servico                                            ³±±
±±³          ³ ExpCA = Tabela de tarifa                                   ³±±
±±³          ³ ExpCB = Indica se o componente se refere a taxa            ³±±
±±³          ³ ExpCC = Componente qd chamado do ajuste (TMSA011)          ³±±
±±³          ³ ExpCD = Pesquisa taxa                                      ³±±
±±³          ³ ExpCE = Verifica se Existe Ajuste para o componente        ³±±
±±³          ³ ExpCF = Regiao Origem da Tabela Mae                        ³±±
±±³          ³ ExpCG = Regiao Destino da Tabela Mae                       ³±±
±±³          ³ ExpCH = Produto da Tabela Mae                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Se encontrou uma tabela                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetTmsTab( cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cTabTar, cTaxa, cCodPas, cPsqTxa, lExistAju, cRgOTab, cRgDTab, cPrdTab, cCodNeg)
	Local lRetorno	:= .F.
	Local nPosicao	:= 0
	Default cTabFre	:= ""
	Default cTipTab	:= ""
	Default cSeqTab	:= ""
	Default cCdrOri	:= ""
	Default cCdrDes	:= ""
	Default cCodCli	:= ""
	Default cLojCli	:= ""
	Default cCodPro	:= ""
	Default cServic	:= ""
	Default cTabTar	:= ""
	Default cTaxa	:= ""
	Default cCodPas	:= ""
	Default cPsqTxa	:= ""
	Default cRgOTab	:= ""
	Default cRgDTab	:= ""
	Default cPrdTab	:= ""
	Default cCodNeg := ""

	If ValType(aTmsTabela) <> 'A'
		Static aTmsTabela := {}
	EndIf

	If Len(aTmsTabela) > 0
		lRetorno := .F.
		nPosicao := Ascan( aTmsTabela, { |x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[8] + x[9] + x[10] + x[11] + x[12] + x[13] + x[15] + x[16] + x[17] + x[19] == cTabFre + cTipTab + cSeqTab + cCdrOri + cCdrDes + cCodCli + cLojCli + cCodPro + cServic + cTabTar + cTaxa + cCodPas + cPsqTxa + cRgOTab + cRgDTab + cPrdTab + cCodNeg .And. x[14] == lExistAju } )

		If nPosicao > 0
			lRetorno := aTmsTabela[ nPosicao, Len(aTmsTabela[ nPosicao] ) - 1]
		EndIf
	EndIf
Return ( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAddReg ³ Autor ³Patricia A. Salomao    ³ Data ³05.02.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adiciona as regioes no vetor aRegiao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAddReg()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array que contem as Regioes                        ³±±
±±³          ³ ExpC1 = Regiao de Origem                                   ³±±
±±³          ³ ExpC2 = Regiao Destino                                     ³±±
±±³          ³ ExpC3 = Valida se o Componente e' Taxa                     ³±±
±±³          ³ ExpC4 = Valida se Pesquisa Estrutura de Regioes            ³±±
±±³          ³ ExpL1 = Se .F. despreza as regioes coligadas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Chamado pela Funcao TMSTabela()                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAddReg(aRegiao, cCdrOri, cCdrDes, cTaxa, cPsqTxa, lRegCol)

Static lRegOri  := SuperGetMv("MV_CALNORI",.F.,.F.)

Local cCdrIni   := ""
Local aRegOri   := {}
Local aRegDUY   := {}
Local nCntFor   := 0
Local nCnt      := 0
Local lPosDUY   := .F.
Local lContinua := .T.

Default lRegCol := .T.

lPsqReg := cTaxa == StrZero(1,Len(DT3->DT3_TAXA)) .Or. cPsqTxa == StrZero(1,Len(DT3->DT3_PSQTXA))

aRegiao := {}
If	lRegCol
	//-- Cache de Estrutura de Regioes habilitado somente quando pesquisa Regioes Coligadas.
	aRegiao := GetAddReg(cCdrOri, cCdrDes, lPsqReg)
EndIf

If Len(aRegiao) == 0
	//-- Adiciona em aRegiao a regiao origem e destino padrao
	AAdd( aRegiao, { cCdrOri, cCdrDes } )
	//-- Se o componente se refere a taxa
	If lPsqReg
		//-- Posiciona em grupos de regioes para verificar regiao coligada, categoria, base para taxa etc...
		DUY->(DbSetOrder(1))
		If	DUY->(MsSeek(xFilial('DUY') + cCdrDes))
			If	lRegCol .And. ! Empty(DUY->DUY_CDRCOL)
				//-- Adiciona em aRegiao a regiao origem e destino coligada
				AAdd( aRegiao, { cCdrOri, DUY->DUY_CDRCOL } )
				If	DUY->(MsSeek(xFilial('DUY') + DUY->DUY_CDRCOL)) .And. ! Empty(DUY->DUY_CDRTAX)
					//-- Verifica se foi especificado regiao para taxa na regiao coligada
					AAdd( aRegiao, { cCdrOri, DUY->DUY_CDRTAX } )
				EndIf
			ElseIf ! Empty(DUY->DUY_CDRTAX)
				//-- Verifica se foi especificado regiao para taxa na regiao destino
				AAdd( aRegiao, { cCdrOri, DUY->DUY_CDRTAX } )
			EndIf
		EndIf

		//-- Procura regiao para taxa na regiao de origem
		If lRegOri
			aRegOri := TmsNivSup( cCdrOri,,lRegCol,aRegDUY )
			lPosDUY := ( Len(aRegOri) == Len(aRegDUY) )
		Else
			AAdd( aRegOri, cCdrOri )
		EndIf

		DUY->(DbSetOrder(1))

		For nCnt := 1 To Len(aRegOri)
			cCdrIni := aRegOri[nCnt]
			lContinua := .T.
			If !lPosDUY .OR. aRegDUY[nCnt] == 0
				lContinua := DUY->(MsSeek(xFilial('DUY') + cCdrIni))
			Else
				DUY->( DbGoto(aRegDUY[nCnt]))
			EndIf
			If	lContinua
				If	lRegCol .And. ! Empty(DUY->DUY_CDRCOL)
					AAdd( aRegiao, { DUY->DUY_CDRCOL, cCdrDes } )
					If	DUY->(MsSeek(xFilial('DUY') + DUY->DUY_CDRCOL)) .And. ! Empty(Iif(lRegOri,cCdrIni,DUY->DUY_CDRTAX))
						//-- Verifica se foi especificado regiao para taxa na regiao origem
						For nCntFor := 1 To Len( aRegiao )
							If	! Empty( aRegiao[ nCntFor, 1 ] ) .And. ! Empty( aRegiao[ nCntFor, 2 ] )
								If Ascan(aRegiao,{ |x| x[1]+x[2] == Iif(lRegOri,cCdrIni,DUY->DUY_CDRTAX)+aRegiao[ nCntFor, 2 ] }) == 0
									AAdd( aRegiao, { Iif(lRegOri,cCdrIni,DUY->DUY_CDRTAX), aRegiao[ nCntFor, 2 ] } )
								EndIf
							EndIf
						Next
					EndIf
				Else
					If ! Empty(Iif(lRegOri,cCdrIni,DUY->DUY_CDRTAX))
						If Ascan(aRegiao,{ |x| x[1]+x[2] == Iif(lRegOri,cCdrIni,DUY->DUY_CDRTAX)+cCdrDes }) == 0
							AAdd( aRegiao, { Iif(lRegOri,cCdrIni,DUY->DUY_CDRTAX), cCdrDes } )
						EndIf
						For nCntFor := 1 To Len( aRegiao )
							If	! Empty( aRegiao[ nCntFor, 1 ] ) .And. ! Empty( aRegiao[ nCntFor, 2 ] )
								If Ascan(aRegiao,{ |x| x[1]+x[2] == Iif(lRegOri,cCdrIni,DUY->DUY_CDRTAX)+aRegiao[ nCntFor, 2 ] }) == 0
									AAdd( aRegiao, { Iif(lRegOri,cCdrIni,DUY->DUY_CDRTAX), aRegiao[ nCntFor, 2 ] } )
								EndIf
							EndIf
						Next
					EndIf
				EndIf
			EndIf
		Next nCnt
	EndIf
	If	lRegCol
		//-- Cache de Estrutura de Regioes habilitado somente quando pesquisa Regioes Coligadas.
		SetAddReg(aRegiao, cCdrOri, cCdrDes, lPsqReg)
	EndIf
EndIf

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SetAddReg ³ Autor ³ Adalberto S.M         ³ Data ³13.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adicionar informacoes da Regiao, funcao TMSAddReg() ao vetor³±±
±±³          ³aTMSAddReg                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SetAddReg(ExpA1, ExpC1, ExpC2, ExpC3, ExpC4)                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array que contem as Regioes                        ³±±
±±³          ³ ExpC1 = Regiao de Origem                                   ³±±
±±³          ³ ExpC2 = Regiao Destino                                     ³±±
±±³          ³ ExpC3 = Valida se o Componente e' Taxa                     ³±±
±±³          ³ ExpC4 = Valida se Pesquisa Estrutura de Regioes            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetAddReg(aRegiao, cCdrOri, cCdrDes, lPsqTxa)
	Default aRegiao := {}
	Default cCdrOri := ""
	Default cCdrDes := ""
	Default lPsqTxa := .F.

	If ValType(aTMSAddReg) <> 'A'
		Static aTMSAddReg := {}
	EndIf

	//////////////////////////////////////////////////////////////////////////
	// Manter o vetor aRegiao sempre na ultima posicao do vetor aTMSAddReg, //
	// para que a funcao GetAddReg() funcione corretamente.                 //
	//////////////////////////////////////////////////////////////////////////
	If Len(aRegiao) > 0
		Aadd( aTMSAddReg, { cCdrOri, cCdrDes, lPsqTxa, aRegiao } )
	EndIf
Return ( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetAddReg ³ Autor ³ Adalberto S.M         ³ Data ³13.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Requisitar informacoes das Regioes existentes no vetor      ³±±
±±³          ³aTMSAddReg. O intuito dessa rotina eh reaproveitar as infor-³±±
±±³          ³macoes ja processadas pela funcao TMSAddReg(), sem que haja ³±±
±±³          ³novamente uma busca na base de dados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GetAddReg(ExpC1, ExpC2, ExpC3, ExpC4)                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Regiao de Origem                                   ³±±
±±³          ³ ExpC2 = Regiao Destino                                     ³±±
±±³          ³ ExpC3 = Valida se o Componente e' Taxa                     ³±±
±±³          ³ ExpC4 = Valida se Pesquisa Estrutura de Regioes            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo dados das Regioes                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetAddReg(cCdrOri, cCdrDes, lPsqTxa)
	Local aRetorno	:= {}
	Local nPosicao	:= 0
	Default cCdrOri := ""
	Default cCdrDes := ""
	Default lPsqTxa := .F.

	If ValType(aTMSAddReg) <> 'A'
		Static aTMSAddReg := {}
	EndIf

	If Len(aTMSAddReg) > 0
		aRetorno := {}
		nPosicao := Ascan( aTMSAddReg, { |x| x[1] + x[2] == cCdrOri + cCdrDes .And. x[3] == lPsqTxa } )
		If nPosicao > 0
			aRetorno := aTMSAddReg[ nPosicao, Len(aTMSAddReg[ nPosicao] ) ]
		EndIf
	EndIf
Return ( aRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSVSegMot³ Autor ³ Alex Egydio           ³ Data ³14.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o motorista tem permissao para transportar o   ³±±
±±³          ³ valor da mercadoria da viagem.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSVSegMot()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial da viagem                                   ³±±
±±³          ³ ExpC2 = Codigo da viagem                                   ³±±
±±³          ³ ExpL1 = .T. Emite aviso se houve restricoes                ³±±
±±³          ³ ExpN1 = Valor da mercadoria                                ³±±
±±³          ³ ExpN2 = Valor maximo permitido                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVSegMot( cFilOri, cViagem, lHelp, nValMerc, nValLim )

Local aAreaAnt    := GetArea()
Local aAreaDA4    := DA4->( GetArea() )
Local aAreaDUP    := DUP->( GetArea() )
Local cSeek       := ''
Local lRet        := .T.

DEFAULT cFilOri	:= ''
DEFAULT cViagem	:= ''
DEFAULT lHelp		:= .F.
DEFAULT nValMerc	:= 0
DEFAULT nValLim	:= 0

//-- Analisa os motoristas informados no complemento da viagem.
DUP->( DbSetOrder( 1 ) )
If	DUP->( MsSeek( cSeek := xFilial('DUP') + cFilOri + cViagem, .F. ) )

	While DUP->( ! Eof() .And. DUP->DUP_FILIAL + DUP->DUP_FILORI + DUP->DUP_VIAGEM == cSeek )
		//-- Se o motorista nao estiver bloqueado verifico se o mesmo tem permissao para
		//-- transportar este valor de mercadoria.
		DA4->( DbSetOrder( 1 ) )
		If	DA4->( MsSeek( xFilial('DA4') + DUP->DUP_CODMOT, .F. ) ) .And.;
			DA4->DA4_BLQMOT == StrZero( 2, Len( DA4->DA4_BLQMOT ) )
			If	nValMerc > DA4->DA4_VALSEG
				If	lHelp
					Help(' ', 1, 'TMSXFUNA09',,CHR(13) + CHR(10) + STR0060 + DA4->DA4_COD + ' - ' + AllTrim(DA4->DA4_NOME) + CHR(13) + CHR(10) +; //"Motorista : "
					STR0061 + Transform( DA4->DA4_VALSEG, PesqPict('DA4','DA4_VALSEG') ) + CHR(13) + CHR(10) +; //"Valor Segurado   "
					STR0062 + Transform( nValMerc, PesqPict('SF2','F2_VALMERC') ),3,11)		//-- Motorista nao tem permissao para transportar este valor de mercadoria.###"Valor Mercadoria "
				EndIf
				lRet := .F.
			EndIf
			//-- Valor de mercadoria que o motorista tem permissao para transportar
			nValLim := DA4->DA4_VALSEG
			Exit
		EndIf

		DUP->( DbSkip() )
	EndDo

Else
	If	lHelp
		Help('', 1, 'TMSXFUNA13',,STR0017 + ':' + cViagem, 4, 1 ) //-- Nao foram informados motoristas para a viagem. (DUP)###"Viagem "
	EndIf
	lRet := .F.
EndIf

RestArea( aAreaDUP )
RestArea( aAreaDA4 )
RestArea( aAreaAnt )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSVldReg³ Autor ³ Alex Egydio           ³ Data ³14.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tratamento especifico qd informa a regiao em uma GetDados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSVldReg()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do campo referente ao Codigo da Regiao        ³±±
±±³          ³ ExpC2 = Nome do campo referente a descricao da Regiao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVldReg(cCodigo,cRegiao)

Local lRet := .T.

M->&(cCodigo) := CriaVar(cCodigo)

lRet := TmsPesqRegiao(cCodigo,cRegiao)
If	!Empty( M->&(cCodigo) )
	GDFieldPut( cCodigo, M->&(cCodigo), n )
EndIf
GDFieldPut( cRegiao, M->&(cRegiao), n )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSSeguro³ Autor ³ Alex Egydio           ³ Data ³25.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo do Seguro e averbacao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSSeguro(ExpC1,ExpC2,ExpC3,ExpL1,ExpA1)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do Docto                                    ³±±
±±³          ³ ExpC2 = No. do Docto                                       ³±±
±±³          ³ ExpC3 = Serie do Docto                                     ³±±
±±³          ³ ExpL1 = Averba seguro do docto                             ³±±
±±³          ³ ExpA1 = Armazena mensagens de erro                         ³±±
±±³          ³ ExpC4 = Tabela de Seguro                                   ³±±
±±³          ³ ExpC5 = Tipo da Tabela de Seguro                           ³±±
±±³          ³ ExpC6 = Calculo da averbacao de seguro da origem e destino ³±±
±±³          ³ ExpA2 = Informacoes adicionais do documento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSSeguro( cFilDoc, cDoc, cSerie, lAverba, aMsgErr, cTabSeg, cTptSeg, aValSeg, aInfDoc, cDocSeg )

Local aDocSav    := {}
Local aRegiao    := {}
Local aRet		  := {}
Local aRetPE	  := {}
Local aTabSeg    := {}
Local lRet		  := .T.
Local lItemSeg   := .F.
Local nCntFor	  := 0
Local nOldCnt    := 0
Local aAvbCli    := {}
Local aAgrRisco  := {}
Local cCodPro    := ''
Local cComSeg    := ''
Local cMsgErr    := ''
Local lHelp      := ( aMsgErr == NIL )
Local nAverbAdic := If(lTMAAVERB,ExecBlock('TMAAVERB',.F.,.F.,{cFilDoc,cDoc,cSerie}),0)
Local nAverbEsp  := 0
Local nVlPreEsp  := 0
Local cSqlOri    := ''
Local cSqlDes    := ''
Local nCnt       := 0
Local n1Cnt      := 0
Local aDoctos    := {}
Local nValMer    := 0
Local cAliasQry  := GetNextAlias()
Local nSeek      := 0
Local nI         := 0
Local lTMSA330   := ( Left(FunName(),7) == "TMSA330" )
Local aSeguro    := {}

Local lDU7DOCSEG := DU7->(ColumnPos("DU7_DOCSEG")) > 0

Default lAverba  := .T.
Default aMsgErr  := {}
Default aValSeg  := {}
Default aInfDoc  := {}
Default cDocSeg  := ''

If ValType(nAverbAdic) <> "N"
	nAverbAdic    := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aRet                                                 ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aRet[1] = Codigo do componente de seguro                              ³
//³ aRet[2] = Valor do premio de seguro a ser pago                        ³
//³ aRet[3] = Codigo do cliente que efetuara a averbacao                  ³
//³ aRet[4] = Loja do cliente que efetuara a averbacao                    ³
//³ aRet[5] = Percentual de averbacao de seguro a ser paga p/ Cliente     ³
//³ aRet[6] = Percentual de agravacao de risco                            ³
//³ aRet[7] = Valor  da tabela de seguro                                  ³
//³ aRet[8] = Fracao da tabela de seguro                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := .F.

If !lTMSA330
	//-- Alimenta o array com informacoes da averbacao do seguro
	cQuery := " SELECT DU7_COMSEG, DU7_PREMIO, DU7_CLIAVB, DU7_LOJAVB, DU7_SEGCLI, DU7_PERAGR, DU7_VALOR, DU7_INTERV "
	cQuery += "    FROM " + RetSqlName("DU7")
	cQuery += "    WHERE DU7_FILIAL = '" + xFilial("DU7") + "' "
	cQuery += "      AND DU7_FILDOC = '" + cFilDoc + "' "
	cQuery += "      AND DU7_DOC    = '" + cDoc    + "' "
	cQuery += "      AND DU7_SERIE  = '" + cSerie  + "' "
	cQuery += "      AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	While !Eof()
		AAdd( aRet, { (cAliasQry)->DU7_COMSEG, (cAliasQry)->DU7_PREMIO, (cAliasQry)->DU7_CLIAVB, (cAliasQry)->DU7_LOJAVB, (cAliasQry)->DU7_SEGCLI, (cAliasQry)->DU7_PERAGR, 0, 0 } )
		If lDU7Valor
			aRet[Len(aRet),7] := (cAliasQry)->DU7_VALOR
			aRet[Len(aRet),8] := (cAliasQry)->DU7_INTERV
		EndIf
		dbSkip()
	EndDo
	(cAliasQry)->(DbCloseArea())
	If !Empty(aRet)
		Return( aRet )
	EndIf
EndIf

//-- Informacoes do seguro
If lPrdDiv
	cQuery := " SELECT DT6.DT6_CDRORI,DT6.DT6_CDRCAL,DTC.DTC_CODPRO, "
	cQuery += " 		 Sum(DTC.DTC_VALOR) DT6_VALMER,DT6.DT6_CLIREM,DT6.DT6_LOJREM, "
	cQuery += " 		 DT6.DT6_CLIDES,DT6.DT6_LOJDES,DT6.DT6_CLIDEV, "
	cQuery += " 		 DT6.DT6_LOJDEV "
	cQuery += " FROM " + RetSqlName("DT6") + " DT6 "
	cQuery += " LEFT JOIN " + RetSqlName("DTC") + " DTC "
	cQuery += "   ON  DTC.DTC_FILIAL  = '" + xFilial("DTC") + "' "
	cQuery += "   AND DTC.DTC_FILDOC = DT6.DT6_FILDOC "
	cQuery += "   AND DTC.DTC_DOC    = DT6.DT6_DOC "
	cQuery += "   AND DTC.DTC_SERIE  = DT6.DT6_SERIE "
	cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery += "   AND DT6.DT6_FILDOC = '" + cFilDoc + "' "
	cQuery += "   AND DT6.DT6_DOC    = '" + cDoc    + "' "
	cQuery += "   AND DT6.DT6_SERIE  = '" + cSerie  + "' "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY DT6.DT6_CDRORI, DT6.DT6_CDRCAL, DTC.DTC_CODPRO,DT6.DT6_CLIREM, DT6.DT6_LOJREM, DT6.DT6_CLIDES, DT6.DT6_LOJDES, DT6.DT6_CLIDEV, DT6.DT6_LOJDEV "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	While (cAliasQry)->(!Eof())
		lRet := .T.
		AAdd( aDoctos, {	(cAliasQry)->DTC_CODPRO, (cAliasQry)->DT6_CDRORI, (cAliasQry)->DT6_CDRCAL,;
								(cAliasQry)->DT6_VALMER, (cAliasQry)->DT6_CLIREM, (cAliasQry)->DT6_LOJREM,;
								(cAliasQry)->DT6_CLIDES, (cAliasQry)->DT6_LOJDES, (cAliasQry)->DT6_CLIDEV,;
								(cAliasQry)->DT6_LOJDEV } )
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Else
	lRet    := .T.
	cCodPro := My_Posicione("DTC",3,xFilial("DTC")+cFilDoc+cDoc+cSerie,"DTC_CODPRO")
	If Len(aInfDoc) > 0
		AAdd( aDoctos, { cCodPro    , aInfDoc[02], aInfDoc[03], aInfDoc[04], aInfDoc[05] , ;
							  aInfDoc[06], aInfDoc[07], aInfDoc[08], aInfDoc[09], aInfDoc[10] } )
	Else
		DT6->(dbSetOrder(1))
		If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
			AAdd( aDoctos, { cCodPro        , DT6->DT6_CDRORI, DT6->DT6_CDRCAL, DT6->DT6_VALMER, DT6->DT6_CLIREM, ;
								  DT6->DT6_LOJREM, DT6->DT6_CLIDES, DT6->DT6_LOJDES, DT6->DT6_CLIDEV, DT6->DT6_LOJDEV } )
		EndIf
	EndIf
EndIf

If lTMSSEGDC
   aDocSav := aClone(aDoctos)
		aDoctos := ExecBlock('TMSSEGDC',.F.,.F.,{aDoctos})
   If ValType(aDoctos) <> 'A'
      aDoctos := aClone(aDocSav)
	EndIf
EndIf
DbSelectArea("DU4")

If Len(aValSeg) == 0
	//-- Posiciona no cabecalho da tabela de seguros
	If	lRet .And. Empty(Posicione("DU4",1,xFilial("DU4")+cTabSeg+cTpTSeg,"DU4_TABSEG"))
		If lHelp
			Help(' ', 1, 'TMSXFUNA20',,STR0063 + cTabSeg + ' / ' + cTpTSeg ,5,11) //-- Tabela de seguro nao encontrada (DU4)###" Tabela : "
		Else
			If !Empty(cTabSeg) .And. !Empty(cTpTSeg)
			   cMsgErr := STR0063 + cTabSeg + ' / ' + cTpTSeg
		     	AAdd(aMsgErr, { cMsgErr + STR0064 ,,"TMSA300()"}) //"Tabela de seguro nao encontrada"
			Else
			   cMsgErr := STR0171 + cFilDoc + "/" + cDoc + "/" + cSerie // "Não existe tabela configurada para o documento: "
		     	AAdd(aMsgErr, { cMsgErr ,," "})
			EndIf
		EndIf
		lRet := .F.
	EndIf
	//-- Verifica se a tabela de seguros esta dentro da data de validade
	If	lRet .And. !TMSTbAtiva( cTabSeg, cTptSeg, lHelp, .T. )
		If !lHelp
			cMsgErr := STR0063 + cTabSeg + ' / ' + cTpTSeg
     		AAdd(aMsgErr, { cMsgErr + STR0065 ,,"TMSA300()"}) //" nao esta dentro da data de validade"
		EndIf
		lRet := .F.
	EndIf
EndIf

If lRet
	cMsgErr   := STR0066 + cTabSeg + ' / ' + cTptSeg + STR0067 + cFilDoc + '-' + cDoc + '/' + cSerie //"Tabela de Seguro :"###" do Docto : "
	For n1Cnt := 1 To Len(aDoctos)
		nValMer += aDoctos[n1Cnt,4]
		//-- Verifica se utiliza produto generico.
		If !Empty(aValSeg) .And. Ascan(aValSeg, { |x| !x[7] } ) == 0
			lRet := .F.
			For nCnt := 1 To Len(aValSeg)
				lRet  := .T.
				AAdd( aRet, { aValSeg[nCnt,1],0,' ',' ',0,0,aValSeg[nCnt,2],aValSeg[nCnt,3],0,0,0 } )
				//-- Sera cobrado o valor a cada intervalo.
				If	aValSeg[nCnt,3] > 0
					aRet[ Len(aRet), 2 ] := ( ( aDoctos[n1Cnt,4] + nAverbAdic ) * aValSeg[nCnt,2] ) / aValSeg[nCnt,3]
				Else
					aRet[ Len(aRet), 2 ] := aValSeg[nCnt,2]
				EndIf
				//-- Verifica agravacao de risco
				If aValSeg[nCnt,8] //-- Se existir agravacao de risco
					//-- Se encontrou agravacao de risco, aplica o percentual ao valor do seguro.
					aAgrRisco := TMSAgrRsc(cTabSeg,cTptSeg,aValSeg[nCnt,1],aDoctos[n1Cnt])
					If !Empty(aAgrRisco) .And. aAgrRisco[1] > 0
						aRet[ Len(aRet), 2 ] := aRet[ Len(aRet), 2 ] + ( aRet[ Len(aRet), 2 ] * ( aAgrRisco[1] / 100 ) )
						aRet[ Len(aRet), 6 ] := aAgrRisco[1]
					EndIf
				EndIf
				//-- Verifica averbacao de seguro pelo cliente
				If aValSeg[nCnt,9] //-- Se existir averbacao de seguro pelo cliente
					aAvbCli := TMSAvbCli( aDoctos[n1Cnt,9], aDoctos[n1Cnt,10], aValSeg[nCnt,1], aDoctos[n1Cnt,5], aDoctos[n1Cnt,6], aDoctos[n1Cnt,7], aDoctos[n1Cnt,8] )
					If !Empty( aAvbCli )
						aRet[ Len(aRet), 2 ] := aRet[ Len(aRet), 2 ] * ( ( 100 - aAvbCli[ 3 ] ) / 100 )
						aRet[ Len(aRet), 3 ] := aAvbCli[ 1 ] //-- Codigo do Cliente
						aRet[ Len(aRet), 4 ] := aAvbCli[ 2 ] //-- Loja
						aRet[ Len(aRet), 5 ] := aAvbCli[ 3 ] //-- Percentual de pagto
					EndIf
				EndIf
				If lTMAAVBESP
					nAverbEsp := ExecBlock('TMAAVBESP',.F.,.F.,{cFilDoc,cDoc,cSerie})
					If ValType(nAverbEsp) <> 'N'
						nAverbEsp := 0
					EndIf
				EndIf

				If nAverbEsp > 0 .And. aValSeg[nCnt,3] > 0
					nVlPreEsp := ( nAverbEsp * aValSeg[nCnt,2] ) / aValSeg[nCnt,3]
					aRet[ Len(aRet), 2 ] += nVlPreEsp
				EndIf

				aRet[ Len(aRet), 09 ] := aDoctos[n1Cnt,4]
				aRet[ Len(aRet), 10 ] := nAverbEsp
				aRet[ Len(aRet), 11 ] := nVlPreEsp

			Next nCnt
		Else

			// Adiciona as Regioes no Vetor aRegiao
			TMSAddReg(@aRegiao,aDoctos[n1Cnt,2],aDoctos[n1Cnt,3],,StrZero(1,Len(DT3->DT3_PSQTXA)))
			AAdd( aRegiao, { Space(Len(DU5->DU5_CDRORI)), Space(Len(DU5->DU5_CDRDES)) } )

			For nCntFor := 1 To Len(aRegiao)
				If !( aRegiao[nCntFor,1] $ cSqlOri )
					cSqlOri += "'" + aRegiao[nCntFor,1] + "',"
				EndIf
				If !( aRegiao[nCntFor,2] $ cSqlDes )
					cSqlDes += "'" + aRegiao[nCntFor,2] + "',"
				EndIf
			Next nCntFor
			If Substr(cSqlOri,Len(cSqlOri)) == ","
				cSqlOri := Substr(cSqlOri,1,Len(cSqlOri) - 1)
			EndIf
			If Substr(cSqlDes,Len(cSqlDes)) == ","
				cSqlDes := Substr(cSqlDes,1,Len(cSqlDes) - 1)
			EndIf
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DU5_COMSEG,DU5_CDRORI,DU5_CDRDES,MAX(DU5_VALOR) DU5_VALOR, "
			cQuery += " 		 MAX(DU5_INTERV) DU5_INTERV, MAX(DU5_CODPRO) DU5_CODPRO "
			cQuery += "   FROM " + RetSqlName("DU5") + " DU5 "
			cQuery += "  WHERE  DU5.DU5_FILIAL = '" + xFilial("DU5") + "' "
			cQuery += "     AND DU5.DU5_TABSEG = '" + cTabSeg + "' "
			cQuery += "     AND DU5.DU5_TPTSEG = '" + cTpTSeg + "' "
			cQuery += "     AND ( DU5.DU5_CODPRO = '" + aDoctos[n1Cnt,1] + "' OR DU5.DU5_CODPRO = '" + cProGen + "' ) "
			cQuery += "     AND DU5.DU5_CDRORI IN ( " + cSqlOri + " ) "
			cQuery += "     AND DU5.DU5_CDRDES IN ( " + cSqlDes + " ) "
			cQuery += "     AND DU5.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY DU5_COMSEG,DU5_CDRORI,DU5_CDRDES "

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

			TCSetField(cAliasQry,"DU5_VALOR" ,"N",TamSx3("DU5_VALOR")[1],TamSx3("DU5_VALOR")[2])
			TCSetField(cAliasQry,"DU5_INTERV","N",TamSx3("DU5_INTERV")[1],TamSx3("DU5_INTERV")[2])
			lRet := .F.

			While (cAliasQry)->(!Eof())
			   //-- Forcar para que a regiao origem / destino do Documento esteja ANTES
			   //-- das Regioes obtidas pela TMSNIVSUP()
	     		nSeek := Ascan(aTabSeg, {|x| x[1]+ x[2]+x[3] == (cAliasQry)->DU5_COMSEG+aDoctos[n1Cnt,2]+aDoctos[n1Cnt,3]})
	        	If nSeek == 0
	            //-- Adiciona no Array as regioes de Origem / destino do DT6
					AAdd(aTabSeg, {(cAliasQry)->DU5_COMSEG,;
									 aDoctos[n1Cnt,2],;
									 aDoctos[n1Cnt,3],;
								   	 0              ,;
								   	 0,;
								   	 Space(Len(DU5->DU5_CODPRO))})
				EndIf

            //-- Verifica se a Regiao de Origem / Destino ja foi incluida no array
		        nSeek := Ascan(aTabSeg, {|x| x[1]+ x[2]+x[3] == (cAliasQry)->DU5_COMSEG+(cAliasQry)->DU5_CDRORI+(cAliasQry)->DU5_CDRDES})
	   			If nSeek == 0
					AAdd(aTabSeg, {(cAliasQry)->DU5_COMSEG,;
					 			   (cAliasQry)->DU5_CDRORI,;
								   (cAliasQry)->DU5_CDRDES,;
								   (cAliasQry)->DU5_VALOR,;
								   (cAliasQry)->DU5_INTERV,;
								   (cAliasQry)->DU5_CODPRO})
				EndIf

				//-- Atualiza os valores da origem  / Destino do documento
				If (cAliasQry)->DU5_COMSEG+(cAliasQry)->DU5_CDRORI+(cAliasQry)->DU5_CDRDES == (cAliasQry)->DU5_COMSEG+aDoctos[n1Cnt,2]+aDoctos[n1Cnt,3]
			        nSeek := Ascan(aTabSeg, {|x| x[1]+ x[2]+x[3] == (cAliasQry)->DU5_COMSEG+aDoctos[n1Cnt,2]+aDoctos[n1Cnt,3]})
			        If nSeek > 0
			        		aTabSeg[nSeek][4] := (cAliasQry)->DU5_VALOR
			        		aTabSeg[nSeek][5] := (cAliasQry)->DU5_INTERV
			        		aTabSeg[nSeek][6] := (cAliasQry)->DU5_CODPRO
			        EndIf
				EndIf

				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())

			If Len(aTabSeg) == 0
				cMsgErr := STR0066 + cSqlOri + ' / ' + cSqlDes +' - ' +STR0069
     			AAdd(aMsgErr, { cMsgErr,,"TMSA300()"}) //" Tabela de seguro : Reg. origem / Reg. destino - nao foi encontrada"
			EndIf

			For nCntFor := 1 To Len(aTabSeg)
				lItemSeg := .F.
				//-- Verifica se ja armazenou valores do seguro para o componente
			   If Ascan(aSeguro, { |x| x[1]+[12] == aTabSeg[nCntFor][1]+aTabSeg[nCntFor][6] }) > 0
					Loop
			   EndIf

			   //-- Se o componente estiver com o valor Zerado
			   If aTabSeg[nCntFor][4] == 0
			   	Loop
			   EndIf

				lRet := .T.
				//-- Se a Origem / Destino for 'Branco'
				If aTabSeg[nCntFor][2]+aTabSeg[nCntFor][3] == Space( Len( DU5->DU5_CDRORI + DU5->DU5_CDRDES ) )  .And. nCntFor < Len(aTabSeg)
					//--  Se existir mais de uma regiao origem / destino para o componente de seguro, antes de considerar a origem / destino em branco,
					//--  vai verificar se existe cadastrado algum item da tabela de seguro para a origem / destino do documento.
				   If aTabSeg[nCntFor][1] == aTabSeg[nCntFor+1][1]
					   Loop
					EndIf
				EndIf

				//-- Se a Origem / Destino da Tabela for igual a Origem / Destino do Documento
				If	aTabSeg[nCntFor][2]+aTabSeg[nCntFor][3] == aDoctos[n1Cnt,2] + aDoctos[n1Cnt,3]
					lItemSeg := .T.
				EndIf

				//-- Se ainda nao encontrou item da Tabela de Seguro para a Regiao Origem / Destino
				If !lItemSeg
					For nI := 1 To Len( aRegiao )
						If aTabSeg[nCntFor][2]+aTabSeg[nCntFor][3]== aRegiao[ nI ][ 1 ] + aRegiao[ nI ][ 2 ]
							lItemSeg := .T.
							Exit
						EndIf
					Next
				EndIf

			   nOldCnt := nCntFor
			   cComSeg := aTabSeg[nCntFor][1]

				//-- Se nao encontrou item da Tabela de Seguro para a Origem / Destino do Documento,
				//-- ira considerar o Item da Tabela com Origem e Destino em Branco
				If !lItemSeg
				   nX := Ascan(aTabSeg,{ |x| x[1]+x[2]+x[3] == cComSeg + Space(Len(DU5->DU5_CDRORI))+  Space(Len(DU5->DU5_CDRDES)) })
				   If nX > 0
						lItemSeg := .T. //-- Considera o Item da Tabela com Origem e Destino em Branco
						nCntFor  := nX
					EndIf
				EndIf

				If lItemSeg
					If Ascan(aValSeg,{ |x| x[1] == aTabSeg[nCntFor][1] } ) == 0
						//-- Armazena valores do seguro. Sera utilizado para o mesmo cliente / regiao
						AAdd( aValSeg, { aTabSeg[nCntFor][1], aTabSeg[nCntFor][4], aTabSeg[nCntFor][5], '', '', 0, (cProGen == aTabSeg[nCntFor][6]), .T., .T. } )
					EndIf

					If (Len(aValSeg) > 0)
						AAdd( aSeguro, { aTabSeg[nCntFor][1], 0, '', '', 0, 0, aTabSeg[nCntFor][4], aTabSeg[nCntFor][5],0, 0, 0, aTabSeg[nCntFor][6]} )

						//-- Sera cobrado o valor a cada intervalo.
						If	aTabSeg[nCntFor][5] > 0
							aSeguro[ Len(aSeguro), 2 ] := ( ( aDoctos[n1Cnt,4] + nAverbAdic ) * aTabSeg[nCntFor][4] ) / aTabSeg[nCntFor][5]
						Else
							aSeguro[ Len(aSeguro), 2 ] := aTabSeg[nCntFor][4]
						EndIf

						//-- Se encontrou agravacao de risco, aplica o percentual ao valor do seguro.
						aAgrRisco := TMSAgrRsc(cTabSeg,cTptSeg,aValSeg[Len(aValSeg),1],aDoctos[n1Cnt])
						If !Empty(aAgrRisco) .And. aAgrRisco[1] > 0
							aSeguro[ Len(aSeguro), 2 ] := aSeguro[ Len(aSeguro), 2 ] + ( aSeguro[ Len(aSeguro), 2 ] * ( aAgrRisco[1] / 100 ) )
							aSeguro[ Len(aSeguro), 6 ] := aAgrRisco[1]
						Else
							aValSeg[Len(aValSeg),8] := .F.
						EndIf

						//-- Verifica averbacao de seguro pelo cliente
						DV6->(dbSetOrder(2))
						If DV6->(MsSeek(xFilial("DV6")+aDoctos[n1Cnt,9]+aDoctos[n1Cnt,10]+aValSeg[Len(aValSeg),1]))
							aAvbCli := TMSAvbCli( aDoctos[n1Cnt,9], aDoctos[n1Cnt,10], aValSeg[Len(aValSeg),1], aDoctos[n1Cnt,5], aDoctos[n1Cnt,6], aDoctos[n1Cnt,7], aDoctos[n1Cnt,8] )
							If !Empty( aAvbCli )
								aSeguro[ Len(aSeguro), 2 ] := aSeguro[ Len(aSeguro), 2 ] * ( ( 100 - aAvbCli[ 3 ] ) / 100 )
								aSeguro[ Len(aSeguro), 3 ] := aAvbCli[ 1 ] //-- Codigo do Cliente
								aSeguro[ Len(aSeguro), 4 ] := aAvbCli[ 2 ] //-- Loja
								aSeguro[ Len(aSeguro), 5 ] := aAvbCli[ 3 ] //-- Percentual de pagto
							EndIf
						Else
							aValSeg[Len(aValSeg),9] := .F.
						EndIf

						If lTMAAVBESP
						   nAverbEsp := ExecBlock('TMAAVBESP',.F.,.F.,{cFilDoc,cDoc,cSerie})
						   If ValType(nAverbEsp) <> 'N'
						   	nAverbEsp := 0
						   EndIf
						EndIf

						If nAverbEsp > 0 .And.aTabSeg[nCntFor][5] > 0
							nVlPreEsp := ( nAverbEsp * aTabSeg[nCntFor][4] ) / aTabSeg[nCntFor][5]
							aSeguro[ Len(aSeguro), 2 ] += nVlPreEsp
						EndIf

						aSeguro[ Len(aSeguro), 09 ] := aDoctos[n1Cnt,4]
						aSeguro[ Len(aSeguro), 10 ] := nAverbEsp
						aSeguro[ Len(aSeguro), 11 ] := nVlPreEsp
					EndIf
				EndIf
		      nCntFor := nOldCnt
			Next
		EndIf
	Next n1Cnt
EndIf

For nCntFor := 1 To Len(aSeguro)
	AAdd( aRet, { aSeguro[ nCntFor,1 ] , aSeguro[nCntFor,2 ] , aSeguro[nCntFor,3 ] , aSeguro[nCntFor,4 ] , aSeguro[nCntFor,5 ] , aSeguro[nCntFor,6 ] ,aSeguro[nCntFor,7 ] , aSeguro[nCntFor,8 ] ,aSeguro[nCntFor,9 ] , aSeguro[nCntFor,10 ] , aSeguro[nCntFor,11 ] } )
Next nCntFor
If lRet
	If	Empty( aRet )
		If lHelp
			Help(' ', 1, 'TMSXFUNA27',, STR0063 + cTabSeg + ' / ' + cTpTSeg + STR0068 + aDoctos[n1Cnt,3] ,4,1)			//-- Item da tabela de seguro nao encontrado (DU5)###" Tabela : "###" Região Destino : "
		Else
	     	AAdd(aMsgErr, { cMsgErr + STR0069 ,,"TMSA300()"}) //" não foi localizada"
		EndIf
	ElseIf lAverba
		For nCntFor := 1 To Len( aRet )
			RecLock("DU7",.T.)
			DU7->DU7_FILIAL := xFilial("DU7")
			DU7->DU7_FILDOC := cFilDoc
			DU7->DU7_DOC    := cDoc
			DU7->DU7_SERIE  := cSerie
			DU7->DU7_COMSEG := aRet[ nCntFor, 1 ]
			DU7->DU7_PREMIO := aRet[ nCntFor, 2 ]
			DU7->DU7_CLIAVB := aRet[ nCntFor, 3 ]
			DU7->DU7_LOJAVB := aRet[ nCntFor, 4 ]
			DU7->DU7_SEGCLI := aRet[ nCntFor, 5 ]
			DU7->DU7_PERAGR := aRet[ nCntFor, 6 ]

			If lDU7Valor
				DU7->DU7_VALOR  := aRet[ nCntFor, 7 ]
				DU7->DU7_INTERV := aRet[ nCntFor, 8 ]
			EndIf

			If lDU7DOCSEG
				DU7->DU7_DOCSEG := cDocSeg
			EndIf
						
			MsUnLock()

			If lTMAGRVSEG
				aRetPE := ExecBlock('TMAGRVSEG',.F.,.F.,{aRet[nCntFor,9],aRet[nCntFor,10],aRet[nCntFor,11],aRet})

				If ValType( aRetPE ) == 'A' .And. ValType( aRetPE[1] ) == 'N' .And. ValType( aRetPE[2] ) == 'N' .And. ValType( aRetPE[3] ) == 'N'
				   aRet[nCntFor,9]  := aRetPE[1]
				   aRet[nCntFor,10] := aRetPE[2]
				   aRet[nCntFor,11] := aRetPE[3]
				EndIf
			EndIf
		Next
	EndIf
EndIf

Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAvbCli³ Autor ³ Richard Anderson      ³ Data ³14.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica de existe averbacao de seguro a ser paga pelo     ³±±
±±³          ³ cliente                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAvbCli(ExpC1,ExpC2,ExpC3,ExpC4,ExpN1)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tabela de seguro                                   ³±±
±±³          ³ ExpC2 = Tipo da tabela de seguro                           ³±±
±±³          ³ ExpC3 = Codigo da regiao origem                            ³±±
±±³          ³ ExpC4 = Codigo da regiao destino                           ³±±
±±³          ³ ExpC5 = Codigo do material                                 ³±±
±±³          ³ ExpN1 = Valor base para calculo do seguro                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAvbCli( cCliDev, cLojDev, cComSeg, cCliRem, cLojRem, cCliDes, cLojDes, lRamo )

Local cEstDes   := ''
Local aRet      := {}
Local cAliasQry := ''
Local cQuery    := ''
Local cCliAvb   := ''
Local cLojAvb   := ''

Default lRamo := .T.  //-- .F. =  ignora o ramo do seguro na query

SA1->( DbSetOrder( 1 ) )
If SA1->( MsSeek( xFilial( 'SA1' ) + cCliDes + cLojDes ) )
	cEstDes := SA1->A1_EST
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analise combinatoria para busca da averbacao de seguro ³
//³por Cliente                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasQry := GetNextAlias()
cQuery := " SELECT DV7.DV7_PAGSEG, DV7.DV7_PERAVB "
cQuery += "   FROM " + RetSqlName("DV6") + " DV6 "
cQuery += "   JOIN " + RetSqlName("DV7") + " DV7 "
cQuery += "     ON  DV6.DV6_FILIAL = '" + xFilial("DV6") + "' "
cQuery += "     AND DV6.DV6_CLIDEV = '" + cCliDev + "' "
cQuery += "     AND DV6.DV6_LOJDEV = '" + cLojDev + "' "
If lRamo
	cQuery += "     AND DV6.DV6_COMSEG = '" + cComSeg + "' "
EndIf
cQuery += "     AND DV6.DV6_INIVIG <= '" + DToS(dDataBase) + "' "
cQuery += "     AND ( DV6.DV6_FIMVIG  = ' ' OR DV6.DV6_FIMVIG >= '" + DToS(dDataBase) + "' )"
cQuery += "     AND DV6.D_E_L_E_T_ = ' ' "
cQuery += "     AND DV7.DV7_FILIAL = '" + xFilial("DV7") + "' "
cQuery += "     AND DV7.DV7_NUMAVB = DV6.DV6_NUMAVB "
cQuery += "     AND ( DV7.DV7_CLIREM = ' ' OR DV7.DV7_CLIREM = '" + cCliRem + "' ) "
cQuery += "     AND ( DV7.DV7_LOJREM = ' ' OR DV7.DV7_LOJREM = '" + cLojRem + "' ) "
cQuery += "     AND ( DV7.DV7_CLIDES = ' ' OR DV7.DV7_CLIDES = '" + cCliDes + "' ) "
cQuery += "     AND ( DV7.DV7_LOJDES = ' ' OR DV7.DV7_LOJDES = '" + cLojDes + "' ) "
cQuery += "     AND ( DV7.DV7_ESTDES = ' ' OR DV7.DV7_ESTDES = '" + cEstDes + "' ) "
cQuery += "     AND DV7.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

If !Eof()
	If (cAliasQry)->DV7_PAGSEG == StrZero( 1, Len( DV7->DV7_PAGSEG ) ) //-- Remetente
		cCliAvb := cCliRem
		cLojAvb := cLojRem
	ElseIf (cAliasQry)->DV7_PAGSEG == StrZero( 2, Len( DV7->DV7_PAGSEG ) ) //-- Destinatario
		cCliAvb := cCliDes
		cLojAvb := cLojDes
	ElseIf (cAliasQry)->DV7_PAGSEG == StrZero( 3, Len( DV7->DV7_PAGSEG ) ) //-- Devedor
		cCliAvb := cCliDev
		cLojAvb := cLojDev
	EndIf
	aRet := { cCliAvb, cLojAvb, (cAliasQry)->DV7_PERAVB }
EndIf

(cAliasQry)->(DbCloseArea())

Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSXFUNA  º Autor º        Nava        º Data º 18/10/01               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   Preenche aHeader e Acols da GetDados retornando Array de Gravacao                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º ValDatHor(dDatDig,cHorDig,dDatAnt,cHorAnt,lTmpLivre,cTermoDig,cTermoAnt)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                                                         º±±
±±º         01 º dDatDig    - Data Digitada                                              º±±
±±º         02 º cHorDig    - Hora Digitada                                              º±±
±±º         03 º dDatAnt    - Data Anterior                                              º±±
±±º         04 º cHorAnt    - Hora Anterior                                              º±±
±±º         05 º lTmpLivre  - Tempo Livre                                                º±±
±±º         06 º cTermoDig  - Termo como Inicial, da Baixa e etc.                        º±±
±±º         07 º cTermoAnt  - Termo como Final  , da Liberacao e etc.                    º±±
±±º         08 º lCompDtHoj - Verifica se podera ser digitada hora maior que hoje        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º Se sao validos os pares Data e Hora                                     º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º TMS - Gestao de Transportes                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º                                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAntonio C F º25/06/02ºxxxxxxº Adequacao de programa.                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ValDatHor(dDatDig,cHorDig,dDatAnt,cHorAnt,lTmpLivre,cTermoDig,cTermoAnt,lCompDtHoj,lAutomat,cMensagem,lDTWAnt)

Local dDatHoj := dDataBase, cHorHoj := Time()
Local lValido := .T. 

dDatDig   := Iif(dDatDig == NIL,Ctod(""),dDatDig)
cHorHoj   := SubStr(cHorHoj,1,2)+Substr(cHorHoj,4,2)
dDatAnt   := Iif(dDatAnt == NIL,Ctod(""),dDatAnt)
cHorAnt   := Iif(cHorAnt == NIL,Space(04),cHorAnt)
lTmpLivre := Iif(lTmpLivre == NIL,.F.,lTmpLivre)
lCompDtHoj:= Iif(lCompDtHoj == NIL,.T.,lCompDtHoj)

DEFAULT cTermoDig := STR0070 //"Final"
DEFAULT cTermoAnt := STR0071 //"Inicial"
DEFAULT lAutomat  := .F.
DEFAULT cMensagem := ""
DEFAULT lDTWAnt   := .F.

If Empty(dDatDig)
	cMensagem := STR0072 //"Data nao pode ser em branco !"
	lValido	 := .F.
ElseIf cHorDig == NIL
	If dDatDig < dDatAnt
		cMensagem := STR0073 + Dtoc(dDatAnt) + ")"  // Data Final###"Data xxxxxx não pode ser menor que Data yyyyyy ("
		cMensagem := StrTran(cMensagem, "xxxxxx", cTermoDig)  // Data Final
		cMensagem := StrTran(cMensagem, "yyyyyy", cTermoAnt)  // Data Inicial

		lValido	:= .F.
	EndIf
	If dDatDig > dDatHoj .And. lCompDtHoj
		If !lValido
			cMensagem += STR0074 //" e; "
		EndIf
		cMensagem += STR0075 + Dtoc(dDatHoj) + ")" //"Data nao pode ser maior que hoje ("
		lValido	:= .F.
	EndIf
Else
	If !(Substr(cHorDig,1,2) < "24" .And. Substr(cHorDig,3,2) < "60")
		cMensagem := STR0076 //"Hora Inválida !"
		lValido	:= .F.
	ElseIf Space(1) $ cHorDig
		cMensagem := STR0076 //"Hora Inválida !"
		lValido	:= .F.
	Else
		If (!lDTWAnt .And. Dtos(dDatDig)+cHorDig <  Dtos(dDatAnt)+cHorAnt) .Or. ;
		   ( lDTWAnt .And. Dtos(dDatDig)+cHorDig <= Dtos(dDatAnt)+cHorAnt)
			If !lDTWAnt
				cMensagem := STR0073 + DTOC(dDatAnt) + " " + TRANSFORM(cHorAnt,"@r 99:99)")  // Data e Hora Final e Data e Hora Inicial###"Data xxxxxx não pode ser menor que Data yyyyyy ("
			Else
				cMensagem := STR0375 + DTOC(dDatAnt) + " " + TRANSFORM(cHorAnt,"@r 99:99)")  // Data e Hora Final e Data e Hora Inicial###"Data xxxxxx não pode ser menor ou igual que Data yyyyyy ("
			EndIf
			cMensagem := StrTran(cMensagem, "xxxxxx", cTermoDig)  // Data e Hora Final
			cMensagem := StrTran(cMensagem, "yyyyyy", cTermoAnt)  // Data e Hora Inicial

			lValido	 := .F.
		EndIf
		If Dtos(dDatDig)+cHorDig > Dtos(dDatHoj)+cHorHoj .And. lCompDtHoj
			If !lValido
				cMensagem += STR0074 //" e; "
			EndIf
			cMensagem += STR0077 + Dtoc(dDatHoj) + " " + Transform(cHorHoj,"@R 99:99)") //"Data e Hora não podem ser maior que a Data e Hora de Hoje ("
			lValido := .F.
		EndIf
	EndIf
EndIf
If !lValido
	If !lAutomat
		Help('',1,'TMSXFUNA42',,cMensagem,3,1) //"Problema de data e/ou hora:"
	EndIf
	If lTmpLivre
		lValido := .T.
	EndIf
EndIf

Return( lValido )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsCtrc  ³ Autor ³ Robson Alves          ³ Data ³15.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao no Carregamento de transporte.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsCtrc(ExpC1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Status                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsCtrc(lStatus, lNoVgeInd , cFilTipTra )

Local cFiltro1   := ""
LOcal cFiltro2   := ""
Local cCadastro  := STR0079 //"Documentos"
Local aRotOld    := Iif(Type("aRotina") <> "U", aClone(aRotina) , {} )
Local aCampos    := {}
Local nRecnoDUD  := 0
Local nFor       := 0
Local lVgeManual := .F.
Local lRegOco    := .F.
Local lTMCPOCTRC := ExistBlock("TMCPOCTRC")
Local lTabDFI    := nModulo<>43
Local nRecnoSF2  := 0
//-- Variaveis para filtro do Browse no DUD
Local aIndexSF2  := {}
Local cFiltraDUD := ""
Local bFiltraBrw := {}
Local oTempTable := NIL
Local cAliasQry  := ""
Local cAliasTRB  := ""
Local aCamposTRB := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina     := {}
Local cNumRom     := ""
Local lVgeTran    := .F.
Local lTMSDCol   := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Local aLoteVge   := {}
Local lVgeMod3   := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local lCarMod3   := Iif(FindFunction("TmsCarMod3"),TmsCarMod3(),.F.) 	//-- Carregamento Modelo 3
Local cFilDocDTA := ""
Local cDocDTA    := ""
Local cSerieDTA  := ""

Private nOpcSel   := 0
//-- Serviço Adicional
If Type("cSerAdi") == "U"
	Private cSerAdi := ""
EndIf

//-- Indica se é um processo de retirada de mercadoria não prevista
If Type("lPrcMerNpr") == "U"
	Private lPrcMerNpr := .F.
EndIf

Default lStatus    	:= .F.
Default lNoVgeInd  	:= .F. //-- Sem viagem para indenizacao
Default cFilTipTra	:= ""  //-- Tipo de transporte

//-- Tratamentos especificos para filtro
cFilTipTra	:= Iif( 'TMSAI40' $ AllTrim( FunName() ) , "4" , "" )
lVgeManual 	:= ( 'TMSA144' $ AllTrim( FunName() ) ) .Or. ('TMSA143' $ AllTrim( FunName() ) .Or. Left(FunName(),7) == 'TMSA153' .Or. Left(FunName(),7) == 'TMSA145' ;
                 .Or. lVgeMod3 )
lRegOco    	:= ( 'TMSA360' $ AllTrim( FunName() ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTabDFI	// - TMS
	If !lVgeMod3
		AAdd(aCampos, "DUD_FILDOC")
		AAdd(aCampos, "DUD_DOC")
		AAdd(aCampos, "DUD_SERIE")
		AAdd(aCampos, "DUD_REGDES")
		If cSerAdi $ ('1/3') .And. cSerTms == StrZero(3, Len(DC5->DC5_SERTMS))
			AAdd(aCampos, "DUD_DESSVT")
		EndIf
	Else
		AAdd(aCampos, "DUD_FILDOC")
		AAdd(aCampos, "DUD_DOC")
		AAdd(aCampos, "DUD_SERIE")
		AAdd(aCampos, "DUD_REGDES")
	EndIf 
Else	// -  OMS
	AAdd(aCampos, "F2_FILIAL")
	AAdd(aCampos, "F2_DOC")
	AAdd(aCampos, "F2_SERIE")
EndIf

If lTmCpoCtrc
	aCpos := ExecBlock('TMCPOCTRC',.F.,.F.)
	If Valtype(aCpos) = 'A'
		For nFor := 1 To Len(aCpos)
			AAdd(aCampos,aCpos[nFor,1])
		Next nFor
	EndIf
EndIf

AAdd( aRotina, { STR0001,"TMSConfSel",0,2,,,.T.} ) // "&Confirmar"

If !lTabDFI	//- TMS
	If lVgeManual .And. !__lPyme .And. !lVgeMod3
		
		If !TmsA144Dc()
			If Type("M->DTQ_VIAGEM") <> "U"
				DTQ->(dbSetOrder(2))
				If DTQ->(dbSeek(xFilial('DTQ')+M->DTQ_FILORI+M->DTQ_VIAGEM))
					cSerAdi  := DTQ->DTQ_SERADI
					If DTQ->DTQ_STATUS == '2'
						lVgeTran := .T.
						If cSerTms == StrZero(3,Len(DTQ->DTQ_SERTMS))
							DTP->(DbSetOrder(3))
							If DTP->(DbSeek(xFilial('DTP')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
								While DTP->(!Eof()) .And. DTP->(DTP_FILIAL+DTP_FILORI+DTP_VIAGEM) == xFilial('DTP')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
									aAdd(aLoteVge,DTP->DTP_LOTNFC)

									DTP->(dbSkip())
								EndDo
							EndIf
						EndIf
					EndIf
				EndIf
				If Empty(cSerAdi) .Or. cSerAdi == '0'					
					Pergunte("TMB144",.F.)
					cSerAdi := mv_par02						
				EndIf
			EndIf
			//-- Quando for o processo de retirada de mercadoria não prevista,
			//-- mesmo que a viagem esteja com status em Trânsito, permite incluir
			//-- tanto solicitação de coleta quanto CTRC
			If lPrcMerNpr
				lVgeTran := .F.
			EndIf
			DUD->(dbSetOrder(6))
			cFiltraDUD := "DUD_FILIAL = '" + xFilial("DUD") + "'" + Iif(lTMSDCol,""," AND DUD_FILORI = '" + cFilAnt + "'") + " AND DUD_TIPTRA = '" + cTipTra + "' AND DUD_STATUS = '1' AND DUD_VIAGEM = ' ' "
			If cSerTms <> StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. ((! Empty(cSerAdi) .And. cSerAdi <> '0') .Or. lPrcMerNpr)
				If lVgeTran
					cFiltraDUD += " AND DUD_SERTMS = '"+cSerAdi+"'"
				Else
					cFiltraDUD += " AND (DUD_SERTMS = '"+cSerTMS+"' OR DUD_SERTMS = '"+cSerAdi+"')"
				EndIf
			Else
				cFiltraDUD += " AND DUD_SERTMS = '"+cSerTMS+"'"
			EndIf
			cFiltraDUD += " AND DUD_NUMRED = ' ' "

			nOpcSel   := TMSC080(cFiltraDUD,,,,aLoteVge)
			nRecnoDUD := DUD->(Recno())
			If nOpcSel == 1
				DUD->(dbGoTo(nRecnoDUD))			

				cFilDocDTA := GDFieldGet('DTA_FILDOC',n)
				cDocDTA    := GDFieldGet('DTA_DOC',n)
				cSerieDTA  := GDFieldGet('DTA_SERIE',n)

				//Destravar o documento antigo caso seja trocado para um novo documento
				If ( cFilDocDTA <> DUD->DUD_FILDOC .And. !Empty(cFilDocDTA) .Or.;
						cDocDTA <> DUD->DUD_DOC .And. !Empty(cDocDTA) .Or.;
						cSerieDTA <> DUD->DUD_SERIE .And. !Empty(cSerieDTA) )
					UnLockByName("VGEDOC" + cFilDocDTA + cDocDTA + cSerieDTA ,.T.,.F.)
				EndIf
				
			EndIf
		EndIf

	ElseIf !IsInCallStack("TMSA360Mnt") .And. ( lVgeMod3 .Or. lCarMod3 )

		nOpcSel	:= TF60F3Doc()
		
		If nOpcSel == 1 
			nRecnoDUD := DUD->(Recno())
			DUD->(dbGoTo(nRecnoDUD))	
		EndIF
		
	ElseIf !__lPyme
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcao de BROWSE.                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lStatus
			cStatus := StrZero(1,Len(DUD->DUD_STATUS)) // "1 - Em Aberto"
			// Esta parte e utilizada pelo Carregamento.
			DUD->(dbSetOrder(4)) // DUD_FILIAL+DUD_FILORI+DUD_STATUS+DUD_VIAGEM
			If DTQ->(Eof())
				cFiltro1   := '"'+xFilial("DUD")+cFilAnt+cStatus+'"'
				cFiltraDUD := "DUD_FILIAL = '" + xFilial("DUD") + "'" + Iif(lTMSDCol,""," AND DUD_FILORI = '" + cFilAnt + "'") + " AND DUD_STATUS = '" + cStatus + "'"
			Else
				cFiltro1   := xFilial("DUD")+DTQ->DTQ_FILORI+cStatus+DTQ->DTQ_VIAGEM
				cFiltraDUD := "DUD_FILIAL = '" + xFilial("DUD") + "'" + Iif(lTMSDCol,""," AND DUD_FILORI = '" + DTQ->DTQ_FILORI  + "'") + " AND DUD_STATUS = '" + cStatus + "' AND DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
				If DUD->( DbSeek( cFiltro1 ) )
					cFiltro1 := '"'+cFiltro1+'"'
				Else
					cFiltro1   := '"'+xFilial("DUD")+cFilAnt+cStatus+Space(Len(DTQ->DTQ_VIAGEM))+'"'
					cFiltraDUD := "DUD_FILIAL = '" + xFilial("DUD") + "'" + Iif(lTMSDCol,""," AND DUD_FILORI = '" + cFilAnt + "'") + " AND DUD_STATUS = '" + cStatus + "' AND DUD_VIAGEM = '" + Space(Len(DTQ->DTQ_VIAGEM)) + "'"
				EndIf
			EndIf
		Else
			DUD->(dbSetOrder(2)) // DUD_FILIAL+DUD_FILORI+DUD_VIAGEM
			If DTQ->(Eof())
				If lNoVgeInd // Esta parte e utilizada pelo Sinistro para pegar somente doctos sem viagem.
					cFiltro1   := '"'+xFilial("DUD")+cFilAnt+Space(Len(DTQ->DTQ_VIAGEM))+'"'
					cFiltraDUD := "DUD_FILIAL = '" + xFilial("DUD") + "'" + Iif(lTMSDCol,""," AND DUD_FILORI = '" + cFilAnt + "'") + " AND DUD_VIAGEM = '" + Space(Len(DTQ->DTQ_VIAGEM)) + "'"
				Else
					cFiltro1   := '"'+xFilial("DUD")+cFilAnt+'"' // Esta parte e utilizada pela Ocorrencia de doctos sem viagem.
					cFiltraDUD := "DUD_FILIAL = '" + xFilial("DUD") + "'" + Iif(lTMSDCol,""," AND DUD_FILORI = '" + cFilAnt + "'")
				EndIf
			Else
				cFiltro1   := '"'+xFilial("DUD")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+'"'
				cFiltraDUD := "DUD_FILIAL = '" + xFilial("DUD") + "'" + Iif(lTMSDCol,""," AND DUD_FILORI = '" + DTQ->DTQ_FILORI + "'") + " AND DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
			EndIf

			If !Empty(cFilTipTra)
				cFiltraDUD	+= " AND DUD_TIPTRA = '" + cFilTipTra + "' "
			EndIf

		EndIf

		nOpcSel   := TMSC080(cFiltraDUD)
		nRecnoDUD := DUD->(Recno())
		If nOpcSel == 1
			DUD->(dbGoTo(nRecnoDUD))
		EndIf

	ElseIf __lPyme

	   cNumRom := Space( Len( DUD->DUD_NUMROM ) )
  		dbSelectArea('DUD')

		If lRegOco
			cNumRom := M->DUA_NUMROM

			DUD->( DbSetOrder ( 8 ) )

			cFiltro1 := '"'+xFilial("DUD")+cNumRom+'"'
			cFiltro2 := cFiltro1

		Else

			DUD->( DbSetOrder ( 9 ) )
			cStatus := StrZero(1,Len(DUD->DUD_STATUS)) // "1 - Em Aberto"
			cFiltro1 := '"'+xFilial("DUD")+cFilAnt+cStatus+cNumRom+'"'

			cStatus := StrZero(3,Len(DUD->DUD_STATUS))
			cFiltro2 := '"'+xFilial("DUD")+cFilAnt+cStatus+cNumRom+'"'

		EndIf

		MaWndBrowse(0,0,300,600,cCadastro,"DUD",aCampos,aRotina,,cFiltro1,cFiltro2,.T.)
	EndIf
ElseIf lRegOco		 //--OMS
	cCadastro := "NF de Saida"
	If !Empty(M->DUA_CODCAR) .And. !Empty(M->DUA_SEQCAR)
		DT2->(dbSetOrder(1))
		DT2->(MsSeek(xFilial("DT2")+GDFieldGet('DUA_CODOCO',n)))
		If	DT2->DT2_TIPOCO == '15'
			cAliasQry := GetNextAlias()
			cAliasTRB := GetNextAlias()
			aCampos   := {}
			AAdd( aCampos, { "F2_FILIAL", "@!", RetTitle("F2_FILIAL") , TamSX3("F2_FILIAL")[1] } )
			AAdd( aCampos, { "F2_DOC"   , "@!", RetTitle("F2_DOC")    , TamSX3("F2_FILIAL")[1] } )
			AAdd( aCampos, { "F2_SERIE" , "@!", RetTitle("F2_SERIE")  , TamSX3("F2_FILIAL")[1] } )

			AAdd(aCamposTRB, { "F2_FILIAL" , "C", TamSX3("F2_FILIAL")[1], TamSX3("F2_FILIAL")[2] })
			AAdd(aCamposTRB, { "F2_DOC"    , "C", TamSX3("F2_DOC")[1], TamSX3("F2_DOC")[2] })
			AAdd(aCamposTRB, { "F2_SERIE"  , "C", TamSX3("F2_SERIE")[1], TamSX3("F2_SERIE")[2] })

			oTempTable := FWTemporaryTable():New(cAliasTRB)
			oTempTable:SetFields( aCamposTRB )
			oTempTable:AddIndex("01", {"F2_FILIAL","F2_DOC","F2_SERIE"} )
			oTempTable:Create()

				BeginSql Alias cAliasQry
				SELECT
					F2_FILIAL, F2_DOC, F2_SERIE
				FROM
					%Table:SF2% SF2, %Table:SD1% SD1,%Table:SF1% SF1
				WHERE
					F2_FILIAL  = %xFilial:SF2% AND
					F2_CARGA   = %Exp:M->DUA_CODCAR% AND
					F2_SEQCAR  = %Exp:M->DUA_SEQCAR% AND
					D1_FILIAL  = %xFilial:SD1% AND
					D1_TIPO    = 'D' AND
					D1_NFORI   = F2_DOC AND
					D1_SERIORI = F2_SERIE AND
					D1_FORNECE = F2_CLIENTE AND
					D1_LOJA    = F2_LOJA AND
					F1_FILIAL  = %xFilial:SF1% AND
					F1_DOC     = D1_DOC AND
					F1_SERIE   = D1_SERIE AND
					F1_FORNECE = D1_FORNECE AND
					F1_LOJA    = D1_LOJA AND
					SF2.%notdel% AND
					SD1.%notdel% AND
					SF1.%notdel%
				GROUP BY
					F2_FILIAL,F2_CARGA,F2_SEQCAR,F2_SERIE,F2_DOC,F2_CLIENTE,F2_LOJA
				ORDER BY
					F2_FILIAL,F2_CARGA,F2_SEQCAR,F2_SERIE,F2_DOC,F2_CLIENTE,F2_LOJA
				EndSql

				While (cAliasQry)->(!Eof())
					RecLock(cAliasTRB,.T.)
					(cAliasTRB)->F2_FILIAL := (cAliasQry)->F2_FILIAL
					(cAliasTRB)->F2_DOC    := (cAliasQry)->F2_DOC
					(cAliasTRB)->F2_SERIE  := (cAliasQry)->F2_SERIE
					MsUnlock()
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
				dbSelectArea(cAliasTRB)
				(cAliasTRB)->(DbGotop())
				MaWndBrowse(0,0,300,600,cCadastro,cAliasTRB,aCampos,aRotina,,,,.T.,,,,,.F.)
				SF2->(dbSetOrder(1))
				SF2->(MsSeek((cAliasTRB)->F2_FILIAL+(cAliasTRB)->F2_DOC+(cAliasTRB)->F2_SERIE))
				//-- Apaga os arquivos temporarios
			oTempTable:Delete()
			dbSelectArea("DUA")
		Else
			SF2->(dbSetOrder(5))
			cFiltro1 := "F2_FILIAL=='"+xFilial("SF2")+"'.And. F2_CARGA=='"+M->DUA_CODCAR+"' .And. F2_SEQCAR=='"+M->DUA_SEQCAR+"' "
			bFiltraBrw := {|| FilBrowse("SF2",@aIndexSF2,@cFiltro1) }
			Eval(bFiltraBrw)
			MaWndBrowse(0,0,300,600,cCadastro,"SF2",aCampos,aRotina,,,,.T.)
			nRecnoSF2 := SF2->(Recno())
			EndFilBrw("SF2",aIndexSF2)
			SF2->(dbGoTo(nRecnoSF2))
		EndIf
	EndIf
EndIf

aRotina := aClone(aRotOld)

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsConfSel³ Autor ³ Richard Anderson      ³ Data ³08.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirma selecao em browse especifico.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSConfSel()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSConfSel()

nOpcSel := 1

If Type("oWind") == "O"
	oWind:End()
Else
	oWnd:End()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se esta na enchoice da cotacao de frete para limpar os campos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ValType("M->DT4_CODSOL") != "U"
	M->DT4_CODSOL := CriaVar("DT4_CODSOL",.F.)
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsConsDTU³ Autor ³ Antonio C Ferreira    ³ Data ³12.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta das Entradas de Veiculos.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsConsDTU(ExpC1,ExpL1,ExpC2,ExpN1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Status a ser considerado na pesquisa de veiculos   ³±±
±±³          ³ ExpL1 - Indica se retorna valores na GETDADOS              ³±±
±±³          ³ ExpC2 - Indica qual campo deve assumir o cont. do retorno  ³±±
±±³          ³ ExpN1 - Indica qual linha deve assumir o cont. do retorno  ³±±
±±³          ³ ExpL2 - Indica se visualiza todas as entradas que nao      ³±±
±±³          ³         estao baixadas                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsConsDTU(cStatus,lRetorna,cCampoRet,nLinha,lNBaixado)

Local cFiltro   := ''
Local cFiltro1  := ''
Local cFiltro2  := ''
Local cCadastro := STR0080 //"Entrada de Veiculos"
Local aRotOld   := aClone(aRotina)
Local aCampos   := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   aRotina := {}
Local aIndexSub := {}
Local cFiltraSub:= ''
Local bFiltraSub
Local lTMDTUFIL := ExistBlock('TMDTUFIL')

DEFAULT cStatus   := "2"
DEFAULT lRetorna  := .F.
DEFAULT cCampoRet := ""
DEFAULT nLinha    := 1
DEFAULT lNBaixado := .F.

Private nOpcSel := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aCampos, "DTU_CODVEI")
AAdd(aCampos, "DTU_MODVEI")
AAdd(aCampos, "DTU_TIPVEI")
AAdd(aCampos, "DTU_NUMENT")
AAdd(aCampos, "DTU_FROVEI")
AAdd(aCampos, "DTU_PLACA" )

AAdd( aRotina, { STR0001,"TMSConfSel",0,2,,,.T.} ) // "&Confirmar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTU->(dbSetOrder(3))
cFiltro1 := '"'+cStatus+'"'
If cStatus == "1" .And. lNBaixado
	cStatus := "3"
EndIf
cFiltro2 := '"'+cStatus+'"'

aIndexSub  := {}
cFiltraSub := 'DTU_FILIAL == "'+xFilial("DTU")+'" .And. DTU_STATUS >= '+cFiltro1 +' .And. DTU_STATUS <= '+cFiltro2
If lTMDTUFIL
   cFiltro := ExecBlock('TMDTUFIL')
   If ValType(cFiltro) = "C" .And. !Empty(cFiltro)
      cFiltraSub := cFiltraSub + " "+cFiltro
   EndIf
EndIf
bFiltraSub := {|| FilBrowse("DTU",@aIndexSub,@cFiltraSub) }
Eval(bFiltraSub)

MaWndBrowse(0,0,300,600,cCadastro,"DTU",aCampos,aRotina,,,,.T.)
aRotina := aClone(aRotOld)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna codigo posicionado                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorna .And. !Empty(cCampoRet) .And. nOpcSel == 1
	GDFieldPut(cCampoRet,DTU->DTU_CODVEI,nLinha)
EndIf
EndFilBrw("DTU",aIndexSub)
Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsConsDTO³ Autor ³ Antonio C Ferreira    ³ Data ³12.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta das Entradas de Motoristas.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsConsDTO(ExpC1,ExpL1,ExpC2,ExpN1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Status a ser considerado na pesquisa de veiculos   ³±±
±±³          ³ ExpL1 - Indica se retorna valores na GETDADOS              ³±±
±±³          ³ ExpC2 - Indica qual campo deve assumir o cont. do retorno  ³±±
±±³          ³ ExpN1 - Indica qual linha deve assumir o cont. do retorno  ³±±
±±³          ³ ExpL2 - Indica se visualiza todas as entradas que nao      ³±±
±±³          ³         estao baixadas                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsConsDTO(cStatus,lRetorna,cCampoRet,nLinha,lNBaixado)

Local cFiltro1  := ''
Local cFiltro2  := ''
Local cCadastro := STR0081 //"Entrada de Motoristas"
Local aRotOld   := aClone(aRotina)
Local aCampos   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   aRotina    := {}
Local   aIndexSub  := {}
Local   cFiltraSub := ''
Local   bFiltraSub
Local   lTMDTOFIL  := ExistBlock('TMDTOFIL')
DEFAULT cStatus   := "2"
DEFAULT lRetorna  := .F.
DEFAULT cCampoRet := ""
DEFAULT nLinha    := 1
DEFAULT lNBaixado := .F.

Private nOpcSel := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aCampos, "DTO_NUMENT")
AAdd(aCampos, "DTO_CODMOT")
AAdd(aCampos, "DTO_NOMMOT")
AAdd(aCampos, "DTO_DATENT")
AAdd(aCampos, "DTO_HORENT")
AAdd(aCampos, "DTO_TIPMOT")

AAdd( aRotina, { STR0001,"TMSConfSel",0,2,,,.T.} ) // "&Confirmar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTO->(dbSetOrder(3))
cFiltro1 := '"'+xFilial("DTO")+cStatus+'"'
If cStatus == "1" .And. lNBaixado
	cStatus := "3"
EndIf
cFiltro2 := '"'+xFilial("DTO")+cStatus+'"'

aIndexSub  := {}
cFiltraSub := 'DTO_FILIAL == "'+xFilial("DTO")+'" .And. DTO_STATUS >= '+cFiltro1 +' .And. DTO_STATUS <= '+cFiltro2
If lTMDTOFIL
	cFiltro := ExecBlock('TMDTOFIL')
	If ValType(cFiltro) = "C" .And. !Empty(cFiltro)
		cFiltraSub := cFiltraSub + " "+cFiltro
	EndIf
EndIf
bFiltraSub := {|| FilBrowse("DTO",@aIndexSub,@cFiltraSub) }
Eval(bFiltraSub)

MaWndBrowse(0,0,300,600,cCadastro,"DTO",aCampos,aRotina,,,,.T.)

aRotina := aClone(aRotOld)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna codigo posicionado                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorna .And. !Empty(cCampoRet) .And. nOpcSel == 1
	GDFieldPut(cCampoRet,DTO->DTO_CODMOT,nLinha)
EndIf
EndFilBrw("DTO",aIndexSub)
Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsEntProc³ Autor ³ Robson Alves          ³ Data ³16.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta das Entradas de Motoristas em processo.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsEntProc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsEntProc()

Local cFiltro1    := ""
Local cFiltro2    := ""
Local aCampos     := {}
Local cStatusDe   := StrZero(1, Len(DTO->DTO_STATUS))
Local cStatusAte  := StrZero(3, Len(DTO->DTO_STATUS))
Local aRotina     := {}

Private cCadastro := STR0081 //"Entrada de Motoristas"
Private nOpcSel   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aCampos, "DTO_NUMENT")
AAdd(aCampos, "DTO_DESSTA")
AAdd(aCampos, "DTO_CODMOT")
AAdd(aCampos, "DTO_NOMMOT")
AAdd(aCampos, "DTO_DATENT")
AAdd(aCampos, "DTO_HORENT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aRotina, { STR0001,"TMSConfSel",0,2,,,.T.} ) // "&Confirmar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTO->(dbSetOrder(3))
cFiltro1 := '"'+xFilial("DTO")+cStatusDe+'"'
cFiltro2 := '"'+xFilial("DTO")+cStatusAte+'"'
MaWndBrowse(0,0,300,600,cCadastro,"DTO",aCampos,aRotina,,cFiltro1,cFiltro2,.T.)

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSLayOutT³ Autor ³ Patricia A. Salomao   ³ Data ³26.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta a Configuracao da Tabela de Frete                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSLayOutTab(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1- Categoria da Tabela:1-Frete a Receber/2-Frete a Pagar³±±
±±³          ³ExpL1- .T. Considera os LayOuts com Data de Inicio de Vigen-³±±
±±³          ³       cia maior que a DataBase.                            ³±±
±±³          ³ExpA1- Array que carrega os Componentes de Frete.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo os elementos da Configuracao (DTL)           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSLayOutTab(cCatTab, lConsDataDe, aTipFaiOk, aTipFaiNo )
Local lUmaCateg := .T.
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local aLayOut   := {}
Local nCont     := 0

Local aTipos := {}
Local nLinha := 0

Default cCatTab     := StrZero(1, Len(DTL->DTL_CATTAB))
Default lConsDataDe := .F. // NAO Considera os LayOuts com Data de Inicio de Vigencia maior que a DataBase.
Default aTipFaiOk   := {}
Default aTipFaiNo   := {}

lUmaCateg := Len(cCatTab) == 1

cQuery := "SELECT DTL.DTL_TABFRE, DTL.DTL_TIPTAB, DTL.DTL_CATTAB, DTL.DTL_DESCRI "
cQuery += " FROM " + RetSqlName("DTL") + " DTL "
cQuery += " INNER JOIN " + RetSqlName("DVE") + " DVE "
cQuery += " ON DTL.DTL_TABFRE = DVE.DVE_TABFRE AND DTL.DTL_TIPTAB = DVE.DVE_TIPTAB "
cQuery += " INNER JOIN " + RetSqlName("DT3") + " DT3 "
cQuery += " ON DVE.DVE_CODPAS = DT3.DT3_CODPAS "
cQuery += " WHERE DTL.DTL_FILIAL = '" + xFilial("DTL") + "' "
cQuery += " AND DVE.DVE_FILIAL = '" + xFilial("DVE") + "' "
cQuery += " AND DT3.DT3_FILIAL = '" + xFilial("DT3") + "' "
If lUmaCateg
	cQuery += " AND DTL.DTL_CATTAB = '" +  cCatTab + "' "
EndIf

cQuery += " AND ( "
If lConsDataDe
	cQuery += " ( DTL.DTL_DATDE >= '" + DtoS(dDataBase) + "' OR DTL.DTL_DATATE = ' ' ) "
Else
	cQuery += " DTL.DTL_DATATE = ' ' "
EndIf
cQuery += " OR DTL.DTL_DATATE >= '" + DtoS(dDataBase) + "' ) "

cQuery += " AND DTL.D_E_L_E_T_ = ' ' "
cQuery += " AND DVE.D_E_L_E_T_ = ' ' "
cQuery += " AND DT3.D_E_L_E_T_ = ' ' "
If !Empty(aTipFaiOk)
	If Len(aTipFaiOk) > 1
		cQuery += "AND DT3.DT3_TIPFAI IN ("
		For nCont := 1 to Len(aTipFaiOk)
			cQuery += " '" + aTipFaiOk[nCont] + "' "
			If nCont <> Len(aTipFaiOk)
				cQuery += ", "
			EndIf
		Next nCOnt
		cQuery += ")"
	Else
		cQuery += " AND DT3.DT3_TIPFAI = '" + aTipFaiOk[1] + "'"
	EndIf
EndIf

If !Empty(aTipFaiNo)
	If Len(aTipFaiNo) > 1
		cQuery += "AND DT3.DT3_TIPFAI NOT IN ("
		For nCont := 1 to Len(aTipFaiNo)
			cQuery += " '" + aTipFaiNo[nCont] + "' "
			If nCont <> Len(aTipFaiNo)
				cQuery += ", "
			EndIf
		Next nCOnt
		cQuery += ")"
	Else
		cQuery += " AND DT3.DT3_TIPFAI <> '" + aTipFaiNo[1] + "'"
	EndIf
EndIf
cQuery += " GROUP BY DTL.DTL_FILIAL, DTL.DTL_TABFRE,DTL.DTL_TIPTAB,DTL.DTL_CATTAB,DTL.DTL_DESCRI "
cQuery += " ORDER BY  " + SqlOrder(DTL->(IndexKey()))
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

If (cAliasQry)->(Eof())
	Help(" ",1,"TMSXFUNA29") //"Inclua ao menos 1 Registro ns Configuracao da Tabela de Frete"
	(cAliasQry)->(dbCloseArea())
	Return(aLayOut)
Else
	aTipos := FwGetSX5("M5")
	While (cAliasQry)->(!Eof())
		nLinha := Ascan(aTipos,{|x| AllTrim(x[3]) == AllTrim((cAliasQry)->DTL_TIPTAB)})
		Aadd( aLayOut, { .F., (cAliasQry)->DTL_TABFRE, (cAliasQry)->DTL_TIPTAB + " - " + ;
				Iif(nLinha > 0,Left(aTipos[nLinha,4],15),Space(15)), ;
				(cAliasQry)->DTL_DESCRI } )
		(cAliasQry)->(DbSkip())
	EndDo
EndIf
(cAliasQry)->(dbCloseArea())

If Len(aLayOut) == 0
	Help(" ",1,"TMSXFUNA11") //"Nao foram encontradas configuracoes ativas ou em vigencia
EndIf

Return( aLayOut )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSTipReg³ Autor ³ Alex Egydio           ³ Data ³25.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a regiao informada eh de origem ou destino.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSTipReg(ExpC1,ExpC2,ExpL1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da regiao                                   ³±±
±±³          ³ ExpC2 = Tipo da Regiao para validacao                      ³±±
±±³          ³ ExpL1 = Valida se devera Mostrar Help                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTipReg( cCdrReg, cTipReg, lHelp )

Local aAreaDTN := DTN->( GetArea() )
Local aAreaDUY := DUY->( GetArea() )
Local aRegiao  := {}
Local aSx3Box  := {}
Local cSeek    := ''
Local nCntFor  := 0
Local lRet     := .T.

DEFAULT cCdrReg := ''
DEFAULT cTipReg := ''
DEFAULT lHelp   := .T.

If ReadVar() == 'M->DUN_CDRDES'
	DUY->(DbSetOrder(1))
	DUY->(MsSeek(xFilial('DUY') + M->DUN_CDRDES))
	If Empty(DUY->DUY_FILDES)
		Help(" ",1,"TMSXFUNA38") //"Campo Filial Destino nao cadastrado."
		lRet := .F.
	Endif
	DUY->(RestArea(aAreaDUY))
Endif

lRet := .F.
//-- O complemento informado para o nivel superior, eh valido para todos os niveis abaixo
aRegiao := TmsNivSup( cCdrReg )
DTN->(DbSetOrder(1))
For nCntFor := 1 To Len(aRegiao)
	If	DTN->(MsSeek(cSeek:=xFilial('DTN') + PadR(aRegiao[nCntFor],Len(DTN->DTN_GRPVEN))))
		While DTN->(!Eof() .And. DTN->DTN_FILIAL + DTN->DTN_GRPVEN == cSeek)
			If	DTN->DTN_TIPREG == StrZero(3,Len(DTN->DTN_TIPREG)) .Or. DTN->DTN_TIPREG == cTipReg
				lRet := .T.
				Exit
			EndIf
			DTN->(DbSkip())
		EndDo
		If	lRet
			Exit
		EndIf
	EndIf
Next

If lHelp .And. !lRet
	aSx3Box := RetSx3Box( My_Posicione('SX3', 2, 'DTN_TIPREG', 'X3CBox()' ),,, 1 )
	Help(" ",1,"TMSXFUNA39",,cCdrReg + CHR(13) + CHR(10) + STR0082 + AllTrim( aSx3Box[ Ascan( aSx3Box, { |x| x[ 2 ] == cTipReg } ) , 3 ] ),1,9) //"Regiao "###" não está configurada como região de "
EndIf

RestArea( aAreaDTN )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsChkDTN³ Autor ³ Alex Egydio           ³ Data ³02.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se a regiao de destino esta habilitada para o tipo  ³±±
±±³          ³ de servico e tipo de transporte do servico digitado.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsChkDTN(ExpC1,ExpC2,ExpC3,ExpL1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Servico de Transporte                              ³±±
±±³          ³ ExpC2 = Tipo de Transporte                                 ³±±
±±³          ³ ExpC3 = Codigo da Regiao                                   ³±±
±±³          ³ ExpL1 = .T. apresenta help                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsChkDTN( cSerTMS, cTipTra, cCdrReg, lHelp, aRegiao )

//Local aAreaDTN	:= DTN->( GetArea() )
Local lRet		:= .T.
Local nCntFor	:= 0

DEFAULT lHelp	:= .T.
DEFAULT aRegiao	:= {}

//-- Se o Servico de Transporte for de 'Coleta', nao validar o Cadastro de Complemento de Regiao.
If cSerTMS == StrZero(1,Len(DTN->DTN_SERTMS))
	Return( .T. )
EndIf

If ! Empty( cCdrReg ) .And. ! Empty( cSerTMS ) .And. ! Empty( cTipTra )
	lRet := .F.
	//-- O complemento informado para o nivel superior, eh valido para todos os niveis abaixo
	If Len(aRegiao) == 0
		aRegiao := TmsNivSup( cCdrReg )
	EndIf
	DTN->(DbSetOrder(2))
	For nCntFor := 1 To Len(aRegiao)
		If	DTN->(MsSeek(xFilial('DTN') + PadR(aRegiao[nCntFor],Len(DTN->DTN_GRPVEN)) + cSerTMS + cTipTra))
			lRet := .T.
			Exit
		EndIf
	Next
EndIf

If	lHelp .And. ! lRet
	Help( ' ', 1, 'TMSXFUNA26',,STR0083 + cSerTMS + '/' + cTipTra + STR0084 + cCdrReg, 5, 1 )	//-- Tipo de servico e/ou transporte desta regiao nao esta habilitado para o servico informado. Verifique o complemento de regioes. (DTN)###"Serviço / Tipo Transp. : "###"  Regiao : "
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsCliCalc³ Autor ³ Alex Egydio           ³ Data ³07.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa a tabela de consignatarios para obter o cliente    ³±±
±±³          ³ utilizado no calculo.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsCliCalc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Cliente remetente                                  ³±±
±±³          ³ ExpC2 = Loja do cliente remetente                          ³±±
±±³          ³ ExpC3 = Cliente destinatario                               ³±±
±±³          ³ ExpC4 = Loja do cliente destinatario                       ³±±
±±³          ³ ExpL1 = .T. Cliente p/calculo do prazo de entrega          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsCliCalc( cCliRem, cLojRem, cCliDes, cLojDes, lPrazo )

Local aAreaAnt := GetArea()
Local aAreaDTI := DTI->( GetArea() )
Local aRet     := {}
Local cCliGen  := GetMV('MV_CLIGEN')
Local cCodGen  := ""
Local cLojGen  := ""
Local aConsig  := {}
Local cCalPrz,cCalFre

DEFAULT lPrazo := .F.

cCodGen := Left(Alltrim(cCliGen),Len(DTC->DTC_CLIREM))
cLojGen := Right(Alltrim(cCliGen),Len(DTC->DTC_LOJREM))

If !TmsConsig(cCliRem,cLojRem,cCliDes,cLojDes,@aConsig)
	If !TmsConsig(cCliRem,cLojRem,cCodGen,cLojGen,@aConsig)
		If !TmsConsig(cCodGen,cLojGen,cCliDes,cLojDes,@aConsig)
			RestArea( aAreaDTI )
			RestArea( aAreaAnt )
			Return( aRet )
		EndIf
	EndIf
EndIf

If lPrazo
	//-- Obtem o cliente para calculo do prazo de entrega.
	cCalPrz := Iif(!Empty(aConsig) .And. Len(aConsig) >= 4, aConsig[3], DTI->DTI_CALPRZ)
	If	cCalPrz == StrZero( 1, Len( DTI->DTI_CALPRZ ) )			//-- Remetente

		aRet := { cCliRem, cLojRem, DTI->DTI_IMPDEV }

	ElseIf	cCalPrz == StrZero( 2, Len( DTI->DTI_CALPRZ ) )		//-- Destinatario

		aRet := { cCliDes, cLojDes, DTI->DTI_IMPDEV }

	ElseIf	cCalPrz == StrZero( 3, Len( DTI->DTI_CALPRZ ) )		//-- Consignatario

		aRet := { DTI->DTI_CLICON, DTI->DTI_LOJCON, DTI->DTI_IMPDEV }

	EndIf
Else
	//-- Obtem o cliente para calculo.
	cCalFre := Iif(!Empty(aConsig) .And. Len(aConsig) >= 4, aConsig[1], DTI->DTI_CALFRE)
	If	cCalFre == StrZero( 1, Len( DTI->DTI_CALFRE ) )			//-- Remetente

		aRet := { cCliRem, cLojRem, DTI->DTI_IMPDEV }

	ElseIf	cCalFre == StrZero( 2, Len( DTI->DTI_CALFRE ) )		//-- Destinatario

		aRet := { cCliDes, cLojDes, DTI->DTI_IMPDEV }

	ElseIf	cCalFre == StrZero( 3, Len( DTI->DTI_CALFRE ) )		//-- Consignatario

		aRet := { DTI->DTI_CLICON, DTI->DTI_LOJCON, DTI->DTI_IMPDEV }

	EndIf
EndIf

RestArea( aAreaDTI )
RestArea( aAreaAnt )

Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsTmpEntr³ Autor ³ Alex Egydio           ³ Data ³08.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula tempo de entrega                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsCliCalc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo de servico                                    ³±±
±±³          ³ ExpC2 = Tipo de transporte                                 ³±±
±±³          ³ ExpC3 = Regiao origem                                      ³±±
±±³          ³ ExpC4 = Regiao destino                                     ³±±
±±³          ³ ExpC5 = Codigo do cliente                                  ³±±
±±³          ³ ExpC6 = Loja do cliente                                    ³±±
±±³          ³ ExpD1 = Data Atual a ser considerada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTmpEntr(cTipTra, cCdrOri, cCdrDes, cCodCli, cLojCli, dDataEnt, cHoraBase, cServico, cCodNeg)

Local lMVTMPNORI := .F. //-- Define se devera subir o nivel da origem para localizacao do tempo.
Local lMVTMSPCOL := .F.//-- Define se devera incluir regioes coligadas para calculo do prazo de entrega.
Local aAreaAnt  := GetArea()
Local aRet      := {}
Local aRegioes  := {}
Local aRegSup   := TmsNivSup(cCdrDes)
Local aRegSupO  := { cCdrOri }
Local aRegBack  := {}
Local nTimeFer  := 0
Local lCliente  := (ValType(cCodCli)=='C' .And. !Empty(cCodCli) )
Local nCnt,nCntSup,nCntSupO
Local nRegCount,cSeek
Local aPerfil   := {}
Local lAchou    := .F.
Local lDiaUtil  := .F.
Local dCorrente
Local dData     := dDatabase
Local nDig      := 3
Local nSomaHora := 0
Local aRetPE    := {}
Local lPrzServ  := AliasIndic('DMO') 

Default dDataEnt	:= dDatabase
Default cHoraBase	:= StrTran(Left(Time(),5),':','')
Default cServico 	:= Space(TamSx3("DT5_SERVIC")[1])
Default cCodNeg		:= Space(TamSx3("DDB_CODNEG")[1])

aRetorno := {}

If DTD->(RecCount()) == 0 .And. DVN->(RecCount()) == 0 .And. !lTMSPRZEN
	Return aRet
EndIf

aRetorno := GetTmpEntr( cTipTra, cCdrOri ,cCdrDes, cCodCli, cLojCli, dDataEnt, cHoraBase, cCodNeg, cServico)

If Len(aRetorno) == 0
	lMVTMPNORI := GetMV("MV_TMPNORI",.F.,.F.)
	lMVTMSPCOL :=GetMV("MV_TMSPCOL",.F.,.T.) 
	
	If lMVTMPNORI
		aRegSupO := TmsNivSup(cCdrOri)
	EndIf
	dCorrente := dDataEnt
	If lCliente
		aPerfil := TmsPerfil(cCodCli,cLojCli)
	Else
		aPerfil := TmsPerfil(Space(Len(DUO->DUO_CODCLI)),Space(Len(DUO->DUO_LOJCLI)))
	EndIf
	//"1"=DIAS UTEIS
	//"2"=DIAS CORRIDOS
	If Len(aPerfil) >= 37 .And. aPerfil[37] == StrZero(1,Len(DUO->DUO_TPDIAS))
		lDiaUtil := .T.
	EndIf

	If lCliente//Se preencher o cliente pesquisa na tabela de prazo de clientes
		
		For nCntSupO := 1 To Len(aRegSupO)
			For nCntSup := 1 To Len(aRegSup)
				TMSAddReg(@aRegioes, aRegSupO[nCntSupO], aRegSup[nCntSup], ,If(!lMVTMPNORI,StrZero(1,Len(DT3->DT3_PSQTXA)),),lMVTMSPCOL)
				//-- Verifica se o indice(2) do arquivo(DVN) foi criado
				DVN->(DbSetOrder(2)) //DVN_FILIAL+DVN_CDRORI+DVN_CDRDES+DVN_TIPTRA+DVN_CODCLI+DVN_LOJCLI
				For nCnt := 1 To Len(aRegioes)
					If	DVN->(!MsSeek(xFilial('DVN') + aRegioes[nCnt,1] + aRegioes[nCnt,2] + cTipTra + cCodCli + cLojCli))
						DVN->( MsSeek(xFilial('DVN') + aRegioes[nCnt,1] + aRegioes[nCnt,2] + cTipTra + cCodCli))
					EndIf
					If DVN->( Found() )
						Exit
					EndIf
				Next
				Aadd(aRegBack , aClone(aRegioes) )//guarda array para nao chamar novamente tmsaddreg
				//-- Se encontrou prazo de regioes por cliente(DVN)
				If DVN->( Found() )
					Exit
				EndIf
				aRegioes := {}
			Next nCntSup
			//-- Se encontrou prazo de regioes por cliente(DVN)
			If DVN->( Found() )
				Exit
			EndIf
		Next nCntSupO
	EndIf

	If	DVN->(Found()) .And. lCliente .And. DVN->DVN_STATUS != StrZero( 1, Len( DVN->DVN_STATUS ))
		If lPrzServ //Busca Prazos x Serviço por clientes
			DMP->(DbSetOrder(1)) //DMP_FILIAL+DMP_CODCLI+DMP_LOJCLI+DMP_CDRORI+DMP_CDRDES+DMP_TIPTRA+DMP_CODNEG+DMP_SERVIC
			If DMP->(MsSeek(xFilial('DMP') + cCodCli + cLojCli + DVN->DVN_CDRORI + DVN->DVN_CDRDES + cTipTra + cCodNeg + cServico))
				cTmpCli := DMP->DMP_TMPENT
			Else
				cTmpCli := DVN->DVN_TMCLIF
			EndIf
		Else
			cTmpCli := DVN->DVN_TMCLIF
		EndIf
		nDig := Len(cTmpCli) - 2 //-- Tamanho Horas menos Minutos
		//-- Obtem o tempo atraves do arquivo prazo de regioes por cliente(DVN)
		AAdd( aRet, IntToHora( TmsHrToInt( DVN->DVN_TMCLII ), nDig ) )
		//-- Tempo Maximo
		AAdd( aRet, IntToHora( TmsHrToInt( cTmpCli ), nDig ) )
		lAchou := .T.
	EndIf
	//ou nao preencheu o cliente ou nao encontrou dados na tabela de prazos por cliente pesquisa pelo prazo de regioes
	If !lAchou
		//-- Posiciona Prazos de Regioes.
		DTD->(DbSetOrder(1)) //DTD_FILIAL+DTD_CDRORI+DTD_CDRDES+DTD_TIPTRA
		For nCntSupO := 1 To Len(aRegSupO)
			For nCntSup := 1 To Len(aRegSup)
				If !lMVTMPNORI .And. Len(aRegBack) > 0//caso tenha procurado as regioes aproveita o processamento
					nRegCount := Len(aRegBack[nCntSup])
				Else
					TMSAddReg(@aRegioes, aRegSupO[nCntSupO], aRegSup[nCntSup], ,If(!lMVTMPNORI,StrZero(1,Len(DT3->DT3_PSQTXA)),),lMVTMSPCOL)
					nRegCount := Len(aRegioes)
				EndIf
				For nCnt :=1 To nRegCount
					If !lMVTMPNORI .And. Len(aRegBack) > 0//caso tenha procurado as regioes aproveita o processamento
						cSeek := xFilial('DTD') + aRegBack[nCntSup,nCnt,1] + aRegBack[nCntSup,nCnt,2] + cTipTra
					Else
						cSeek := xFilial('DTD') + aRegioes[nCnt,1] + aRegioes[nCnt,2] + cTipTra
					EndIf
					If DTD->( MsSeek( cSeek , .F. ) )						
						nDig := 3
						nSomaHora := TmsHrToInt( DTD->DTD_TMEMBI ) + TmsHrToInt( DTD->DTD_TMTRAI ) + TmsHrToInt( DTD->DTD_TMDISI )
						If nSomaHora > 999
							nDig := Len(Alltrim(Str(nSomaHora)))
						EndIf
						//-- Soma o tempo Minimo.
						AAdd( aRet, IntToHora( TmsHrToInt( DTD->DTD_TMEMBI ) + TmsHrToInt( DTD->DTD_TMTRAI ) + TmsHrToInt( DTD->DTD_TMDISI ), nDig) )
						nDig := 3
						nSomaHora := TmsHrToInt( DTD->DTD_TMEMBF ) + TmsHrToInt( DTD->DTD_TMTRAF ) + TmsHrToInt( DTD->DTD_TMDISF )
						If nSomaHora > 999
							nDig := Len(Alltrim(Str(nSomaHora)))
						EndIf
						If lPrzServ //Busca Prazos x Serviço por clientes
							DMO->(DbSetOrder(1)) //DMO_FILIAL+DMO_CDRORI+DMO_CDRDES+DMO_TIPTRA+DMO_CODNEG+DMO_SERVIC
							If DMO->(MsSeek(xFilial('DMO') + DTD->DTD_CDRORI + DTD->DTD_CDRDES + cTipTra + cCodNeg + cServico))
								AAdd( aRet, IntToHora( TmsHrToInt( DMO->DMO_TMPENT ), nDig) )
							Else
								//-- Soma o tempo Maximo.
								AAdd( aRet, IntToHora( TmsHrToInt( DTD->DTD_TMEMBF ) + TmsHrToInt( DTD->DTD_TMTRAF ) + TmsHrToInt( DTD->DTD_TMDISF ), nDig) )
							EndIf
						Else
							//-- Soma o tempo Maximo.
							AAdd( aRet, IntToHora( TmsHrToInt( DTD->DTD_TMEMBF ) + TmsHrToInt( DTD->DTD_TMTRAF ) + TmsHrToInt( DTD->DTD_TMDISF ), nDig) )
						EndIf
						lAchou := .T.
						Exit
					EndIf
				Next
				If lAchou //se ja achou resultado abandona loop
					Exit
				Else
					aRegioes := {}
				EndIf
			Next nCntSup
			If lAchou //se ja achou resultado abandona loop
				Exit
			EndIf
		Next nCntSupO
	EndIf

	If lAchou
		dData := dCorrente
		For nCnt := 1 To TmsHrToInt( aRet[ 2 ] ) / nMVHrPrz
			dCorrente := TmsHrFer(dCorrente, cCdrDes, lDiaUtil)
			If dCorrente == dData 
				dCorrente+= 1
			ElseIf lDiaUtil
				nTimeFer += (dCorrente - dData ) * nMVHrPrz //soma as horas do fim de semana caso DUO_TPDIAS=2
				nCnt--
			EndIf
			dData := dCorrente
		Next nCnt
		
		nTimeFer += (TmsHrFer(dCorrente, cCdrDes, lDiaUtil)-dCorrente) * nMVHrPrz

		nDig := 3
		nSomaHora := (TmsHrToInt(aRet[2]) + nTimeFer)//soma as horas que localizou do prazo de clientes ou regiões, com as horas do fim de semana/feriado
		If nSomaHora > 999
			nDig := Len(Alltrim(Str(nSomaHora)))
		EndIf
		aRet[2] := IntToHora( TmsHrToInt(aRet[2]) + nTimeFer , nDig )
	EndIf

	If lTMSPRZEN
		aRetPE := ExecBlock("TMSPRZEN",.F.,.F.,{cTipTra,cCdrOri,cCdrDes,cCodCli,cLojCli,dDataEnt,cHoraBase,aRet})
		If ValType( aRetPE ) == 'A' .And. Len(aRetPE) > 0
			aRet:= aRetPE
		EndIf
	EndIf
	SetTmpEntr( cTipTra, cCdrOri ,cCdrDes, cCodCli, cLojCli, dDataEnt, cHoraBase, cCodNeg, cServico, aRet)
Else
	aRet := aClone(aRetorno)
EndIf

RestArea( aAreaAnt )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aRet                                                 ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aRet[ 1 ] = Totalizador dos tempos iniciais                           ³
//³ aRet[ 2 ] = Totalizador dos tempos finais                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( aRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SetTmpEntr³ Autor ³ Katia Bianchi         ³ Data ³21.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adicionar informacoes do tempo de entraga funcao            ³±±
±±³          ³TMSTMPENTR() ao vetor aTMSTmpEntr                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SetTmpEntr( ExpC1, ExpC2, ExpD1, ExpC3, ExpC4, ExpC5, ExpC6,³±±
±±³          ³            ExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Tipo de Transporte                                  ³±±
±±³          ³ExpC2 - Codigo regiao origem                                ³±±
±±³          ³ExpD1 - Codigo regiao destino                               ³±±
±±³          ³ExpC3 - Codigo Cliente                                      ³±±
±±³          ³ExpC4 - Loja Cliente                                        ³±±
±±³          ³ExpC5 - Data entrega                                        ³±±
±±³          ³ExpC6 - Hora base                                           ³±±
±±³          ³ExpA1 - Vetor contendo todas as informacoes do Tempo de Entr³±±
±±³          ³        Essas informacoes sao geradas pela funcao TMSTMPENTR³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetTmpEntr(cTipTra, cCdrOri ,cCdrDes, cCodCli, cLojCli, dDataEnt, cHoraBase, cCodNeg, cServico, aRet)
	Default aRet		:= {}
	Default cTipTra	:= ""
	Default cCdrOri	:= ""
	Default cCdrDes	:= ""
	Default cCodCli	:= ""
	Default cLojCli	:= ""
	Default dDataEnt	:= ""
	Default cHoraBase	:= ""

	If ValType(aTMSTmpEntr) <> 'A'
		Static aTMSTmpEntr := {} 
	EndIf

    /////////////////////////////////////////////////////////////////////////////
    // Manter o vetor aRet sempre na ultima posicao do vetor aTMSTmpEntr, //
    // para que a funcao GetTmpEntr() funcione corretamente.                   //
    /////////////////////////////////////////////////////////////////////////////
	If Len(aRet) > 0
		Aadd( aTMSTmpEntr, { cTipTra, cCdrOri, cCdrDes, cCodCli, cLojCli, DtoS(dDataEnt), cHoraBase, cCodneg, cServico, aRet } )
	EndIf
Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetTmpEntr³ Autor ³ Adalberto S.M         ³ Data ³12.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Requisitar informacoes do tempo de entrega existentes vetor ³±±
±±³          ³aTMSTmpEntr. O intuito dessa rotina eh reaproveitar as in-  ³±±
±±³          ³formacoes ja processadas pela funcao TMSTMPENTR(), sem que  ³±±
±±³          ³haja novamente uma busca na base de dados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SetTmpEntr( ExpC1, ExpC2, ExpD1, ExpC3, ExpC4, ExpC5, ExpC6,³±±
±±³          ³            ExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Tipo de Transporte                                  ³±±
±±³          ³ExpC2 - Codigo regiao origem                                ³±±
±±³          ³ExpD1 - Codigo regiao destino                               ³±±
±±³          ³ExpC3 - Codigo Cliente                                      ³±±
±±³          ³ExpC4 - Loja Cliente                                        ³±±
±±³          ³ExpC5 - Data entrega                                        ³±±
±±³          ³ExpC6 - Hora base                                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo dados do Contrato                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetTmpEntr( cTipTra, cCdrOri ,cCdrDes, cCodCli, cLojCli, dDataEnt, cHoraBase, cCodneg, cServico)
	Local aRetorno	:= {}
	Local nPosicao	:= 0
	Default cTipTra	:= ""
	Default cCdrOri	:= ""
	Default cCdrDes	:= ""
	Default cCodCli	:= ""
	Default cLojCli	:= ""
	Default dDataEnt	:= ""
	Default cHoraBase	:= ""
	Default cCodneg		:= ""
	Default	cServico	:= ""

	If ValType(aTMSTmpEntr) <> 'A'
		Static aTMSTmpEntr := {}
	EndIf

	If Len(aTMSTmpEntr) > 0
		aRetorno := {}
		nPosicao := Ascan( aTMSTmpEntr, { |x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[8] + x[9]  == cTipTra + cCdrOri + cCdrDes + cCodCli + cLojCli + DtoS(dDataEnt) + cHoraBase + cCodNeg + cServico } )

		If nPosicao > 0
			aRetorno := aTMSTmpEntr[ nPosicao, Len(aTMSTmpEntr[ nPosicao] ) ]
		EndIf
	EndIf
Return ( aRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsHrFer  ³ Autor ³ Henry Fila            ³ Data ³08.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Traz a proxima data valida para entrega                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsHrFer()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data a ser pesquisada                              ³±±
±±³          ³ ExpC2 = Regiao de destino                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Proxima data valida                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsHrFer(dDataEnt,cCdrDes,lDiaUtil,aRegiao)

Local aArea      := GetArea()
Local aAreaDV8   := DV8->(GetArea())
Local cDiaMes    := ''
Local cAno       := ''
Local nI         := 0
Local lFerMun    := .F.
Local lFerReg    := .F.
Local aFerMun    := {}
Local aFerReg    := {}

Default lDiaUtil := .F.
Default aRegiao  := {}

dDataEnt := DtValid(dDataEnt,.T.,.F.)

If lDiaUtil
	//-- SABADO
	If Dow(dDataEnt) == 7
		dDataEnt++
	EndIf
	//-- DOMINGO
	If Dow(dDataEnt) == 1
		dDataEnt++
	EndIf
EndIf

cDiaMes  := SubStr(DtoC(dDataEnt),1,5)
cAno     := StrZero(Year(dDataEnt),4)

//-- Pesquisa Feriados Municipais
If lCxTabFer != NIL .And. lCxTabFer  //cache da tabela de feriados municipais
	VarRef( aFerMun, aCxTabFer[1] )
	lFerMun := aScan( aFerMun, {|x| x[1]+x[2]+x[3]+x[4]==xFilial("DV8")+cCdrDes+cDiaMes+cAno} ) > 0
Else         //modo normal - pesquisa chave completa
	aAreaDV8   := DV8->(GetArea())
	DV8->(dbSetOrder(1)) //DV8_FILIAL+DV8_DIAMES+DV8_ANO+DV8_CDRDES
	lFerMun := DV8->(MsSeek(xFilial("DV8")+cDiaMes+cAno+cCdrDes))
EndIf
If	lFerMun //DV8->(MsSeek(xFilial("DV8")+cDiaMes+cAno+cCdrDes))
	dDataEnt += 1
	dDataEnt := TmsHrFer(dDataEnt,cCdrDes,lDiaUtil,aRegiao)
Else
	If lCxTabFer != NIL .And. lCxTabFer //cache da tabela de feriados municipais
		lFerMun := aScan( aFerMun, {|x| x[1]+x[2]+x[3]+x[4]==xFilial("DV8")+cCdrDes+cDiaMes+Space(Len(DV8->DV8_ANO))} ) > 0
	Else        //modo normal - pesquisa sem o ano
		lFerMun := DV8->(MsSeek(xFilial("DV8")+cDiaMes+Space(Len(DV8->DV8_ANO))+cCdrDes))
	EndIf
	If lFerMun //DV8->(MsSeek(xFilial("DV8")+cDiaMes+Space(Len(DV8->DV8_ANO))+cCdrDes))
		dDataEnt += 1
		dDataEnt := TmsHrFer(dDataEnt,cCdrDes,lDiaUtil,aRegiao)
	Endif
Endif

If lCxTabFer == NIL
	RestArea(aAreaDV8)
EndIf

//-- Pesquisa Feriados Regionais
If lCxTabFer != NIL .And. lCxTabFer   //cache da tabela de Feriados Regionais
	VarRef( aFerReg, aCxTabFer[2] )
	lFerReg := aScan( aFerReg, {|x| x[1]+x[2]+x[3]==xFilial("DWY")+cCdrDes+cDiaMes} )  > 0

Else //modo normal - pesquisa chave DiaMes em Feriados Regionais
	DWY->(dbSetOrder(1)) //DWY_FILIAL+DWY_DIAMES+DWY_ANO+DWY_CDRDES
	lFerReg := DWY->(MsSeek(xFilial("DWY")+cDiaMes))
EndIf
If	lFerReg             //DWY->(MsSeek(xFilial("DWY")+cDiaMes))
	If Len(aRegiao) == 0
		aRegiao := TMSNivSup(cCdrDes)
	EndIf
	For nI := 1 To Len(aRegiao)
		If lCxTabFer != NIL .And. lCxTabFer   //cache da tabela de Feriados Regionais
			lFerReg := aScan( aFerReg, {|x| x[1]+x[2]+x[3]+x[4]==xFilial("DWY")+aRegiao[nI]+cDiaMes+cAno} )  > 0
		Else           //modo normal procura chave completa
			lFerReg := DWY->(MsSeek(xFilial("DWY")+cDiaMes+cAno+aRegiao[nI]))
		EndIf
		If	lFerReg  //DWY->(MsSeek(xFilial("DWY")+cDiaMes+cAno+aRegiao[nI]))
			dDataEnt += 1
			dDataEnt := TmsHrFer(dDataEnt,cCdrDes,lDiaUtil,aRegiao)
			Exit
		Else
			If lCxTabFer != NIL .And. lCxTabFer
				lFerReg := aScan( aFerReg, {|x| x[1]+x[2]+x[3]+x[4]==xFilial("DWY")+aRegiao[nI]+cDiaMes+Space(Len(DWY->DWY_ANO))} )  > 0
			Else      //modo normal procura chave sem o ano
				lFerReg := DWY->(MsSeek(xFilial("DWY")+cDiaMes+Space(Len(DWY->DWY_ANO))+aRegiao[nI]))
			EndIf
			If lFerReg    //DWY->(MsSeek(xFilial("DWY")+cDiaMes+Space(Len(DWY->DWY_ANO))+aRegiao[nI]))
				dDataEnt += 1
				dDataEnt := TmsHrFer(dDataEnt,cCdrDes,lDiaUtil,aRegiao)
				Exit
			Endif
		Endif
	Next nI
EndIf

//RestArea(aAreaDV8)
RestArea(aArea)

Return( dDataEnt )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmsCxTabFer ºAutor  ³Microsiga         º Data ³  16/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³cache das tabelas DV8 e DWY - Feriados Municip. e Regionais º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TmsCxTabFer()
Local cQuery := ""
Local cTabFerMun := GetNextAlias()
Local cTabFerReg := GetNextAlias()

If lCxTabFer == NIL   //indicativo se trabalha com cache da tabela DV8 - Feriados Municipais e tabela DWY - Feriados Regionais

	aCxTabFer := {}
	aAdd( aCxTabFer, {} )  //elemento 1 contera os feriados municipais tabela DV8
	aAdd( aCxTabFer, {} )  //elemento 2 contera os feriados regionais tabela DWY
	//query para cache dos feriados municipais tabela DV8
	cQuery := "SELECT DISTINCT DV8_FILIAL,DV8_CDRDES,DV8_DIAMES,DV8_ANO FROM "+RetSqlName("DV8")
	cQuery += " WHERE DV8_FILIAL = '"+xFilial("DV8")+"' AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabFerMun)
	While (cTabFerMun)->(! Eof() )
		(cTabFerMun)->( aAdd(aCxTabFer[1], {DV8_FILIAL,DV8_CDRDES,DV8_DIAMES,DV8_ANO} ) )
		(cTabFerMun)->( dbSkip() )
	EndDo
	(cTabFerMun)->( dbCloseArea() )

	//query para cache dos feriados regionais tabela DWY
	cQuery := "SELECT DISTINCT DWY_FILIAL,DWY_CDRDES,DWY_DIAMES,DWY_ANO FROM "+RetSqlName("DWY")
	cQuery += " WHERE DWY_FILIAL = '"+xFilial("DWY")+"' AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabFerReg)
	While (cTabFerReg)->(! Eof() )
		(cTabFerReg)->( aAdd(aCxTabFer[2], {DWY_FILIAL,DWY_CDRDES,DWY_DIAMES,DWY_ANO} ) )
		(cTabFerReg)->( dbSkip() )
	EndDo
	(cTabFerReg)->( dbCloseArea() )
	lCxTabFer := .T.  //Seta variavel para indicar que trabalha com cache

EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsValFiel³ Autor ³Patricia A. Salomao    ³ Data ³15.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o campo Informado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsValField()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome do Campo                                      ³±±
±±³          ³ ExpL1 - Valida o Conteudo Informado no Campo               ³±±
±±³          ³ ExpC2 - Campo de Descricao                                 ³±±
±±³          ³ ExpL2 - Seleciona opcao via consulta F3                    ³±±
±±³          ³ ExpL3 - Retorno de array com as opcoes                     ³±±
±±³          ³ ExpL4 - Acrescenta uma opcao "Todos"                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSValField(cCampo,lValid,cCpoDes,lConsF3,lArray,lTodos, lAllSERTMS, lFastAnytc)

Static cMvTmsDoc := GetMv("MV_TMSDOC",,'')
Static cMvSerTms := GetMv("MV_SERTMS",,'')
Static lTmsCFec  := TmsCFec()
Static lTabDFI   := nModulo<>43
Static lTmDescri := ExistBlock('TMDESCRI')

Local aArea		 := GetArea()
Local aAreaDT2   := DT2->( GetArea() )
Local aRet       := {}
Local aRet2      := {}
Local cDesc      := ""
Local cTexto     := ""
Local cTitulo    := ''
Local lRet       := .F.
Local nTmsItem   := 0
Local nPosIni    := 0
Local nTamIni    := 0
Local xRet       := NIL
Local lTMSExp    := TMSExp()
Local nA         := 0
Local nPosDocto  := 0
Local lCmpRatNew := DDA->(ColumnPos("DDA_CRIRAT"))> 0
Local lRomaneio  := .F.
Local lNewTDA	 := DUO->(ColumnPos("DUO_TDAREG"))> 0

DEFAULT cCampo := ReadVar()
DEFAULT lValid := .T.
DEFAULT lConsF3:= .F.
DEFAULT lArray := .F.
DEFAULT lTodos := .F.
DEFAULT lAllSERTMS 	:= .F.
Default lFastAnytc	:= .F.

If "SERTMS" $ Upper( cCampo ) .Or. "SERADI" $ Upper( cCampo )

	lRet := .T.

	If !lTabDFI	.OR. lAllSERTMS		 //--TMS
		If "SERADI" $ Upper( cCampo )
			If ( nPosIni := At("0=",cMvSerTms)) <> 0
				nPosIni += 2
				nTamIni := At(";",Substr(cMvSerTms,nPosIni)) - 1
				If nTamIni <= 0
		   			nTamIni := Len(Alltrim(Substr(cMvSerTms,nPosIni))) + 1
				EndIf
				AAdd( aRet, { "0", Substr(cMvSerTms,nPosIni,nTamIni) })
			Else
				AAdd( aRet, { "0", "Não Utiliza" })
			EndIf
		EndIf

		If ( nPosIni := At("1=",cMvSerTms)) <> 0
			nPosIni += 2
			nTamIni := At(";",Substr(cMvSerTms,nPosIni)) - 1
			If nTamIni <= 0
		   		nTamIni := Len(Alltrim(Substr(cMvSerTms,nPosIni))) + 1
			EndIf
			AAdd( aRet, { "1", Substr(cMvSerTms,nPosIni,nTamIni) })
		Else
			AAdd( aRet, { "1", STR0085 }) //"Coleta"
		EndIf

		If "SERTMS" $ Upper( cCampo )
			If ( nPosIni := At("2=",cMvSerTms)) <> 0
				nPosIni += 2
				nTamIni := At(";",Substr(cMvSerTms,nPosIni)) - 1
				If nTamIni <= 0
		   		nTamIni := Len(Alltrim(Substr(cMvSerTms,nPosIni))) + 1
				EndIf
				AAdd( aRet, { "2", Substr(cMvSerTms,nPosIni,nTamIni) })
			Else
				AAdd( aRet, { "2", STR0086 }) //"Transporte"
			EndIf
		EndIf
	EndIf

	If "SERTMS" $ Upper( cCampo )
		If ( nPosIni := At("3=",cMvSerTms)) <> 0
			nPosIni += 2
			nTamIni := At(";",Substr(cMvSerTms,nPosIni)) - 1
			If nTamIni <= 0
	   		nTamIni := Len(Alltrim(Substr(cMvSerTms,nPosIni))) + 1
			EndIf
			AAdd( aRet, { "3", Substr(cMvSerTms,nPosIni,nTamIni) })
		Else
			AAdd( aRet, { "3", STR0087 }) //"Entrega"
		EndIf
	EndIf

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DC5_SERTMS', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] == AllTrim(&(cCampo)) }) == 0
				cTexto := STR0088 //"Servico de Transporte Invalido !"
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf "TIPTRA" $ Upper( cCampo )

	lRet := .T.
	AAdd( aRet, { '1', STR0091		}) //"Rodoviario"
	AAdd( aRet, { '2', STR0092		}) //"Aereo"
	AAdd( aRet, { '3', STR0093		}) //"Fluvial"
	AAdd( aRet, { '4', STR0174		}) //"Rodoviario Internacional"
	AAdd( aRet, { '6', STR0348		}) //"Multimodal"
	If lTodos
		AAdd( aRet, { '9', STR0094	}) //"Todos"
	EndIf
	If !lArray
		If	lConsF3
			If Upper( cCampo )=="M->DFT_TIPTRA" //- Tipo de Transporte do Redespacho
				cTitulo := My_Posicione('SX3', 2, 'DFT_TIPTRA', 'X3Titulo()')
			Else
				cTitulo := My_Posicione('SX3', 2, 'DC5_TIPTRA', 'X3Titulo()')
			EndIf
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				If !Upper( cCampo )=="M->DFT_TIPTRA"
					cTexto := STR0095 //"Tipo de Transporte Invalido !"
					Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				EndIf
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf "DOCTMS" $ Upper( cCampo ) .Or. "DOCFAT" $ Upper( cCampo ) .OR. ( lRomaneio := "TMSDOCROMANEIO" $ Upper( cCampo ) )

	lRet := .T.
	If !lRomaneio
		AAdd( aRet, { '1', STR0096		}) //"Ordem de Coleta"
	EndIf
	AAdd( aRet, { '2', STR0097		}) //"CTRC"
	If FunName() != "DLGA070" .AND. !lRomaneio
		AAdd( aRet, { '3', STR0098		}) //"AWB"
	EndIf

	If !lRomaneio
		AAdd( aRet, { '4', STR0099		}) //"Docto.Bx.Estoque"
	EndIf
	AAdd( aRet, { '5', STR0100		}) //"Nota Fiscal"
	AAdd( aRet, { '6', STR0101		}) //"CTRC Devolucao"
	AAdd( aRet, { '7', STR0102		}) //"CTRC Reentrega"

	If !lRomaneio
		AAdd( aRet, { '8', STR0103		}) //"CTRC Complemento"
		AAdd( aRet, { '9', STR0104		}) //"CTRC Retorno"
		AAdd( aRet, { 'A', STR0105		}) //"CTRC Cortesia"
	EndIf

	If lTmsCFec
		If ( nPosIni := At("B=",cMvTmsDoc)) <> 0
			nPosIni += 2
			nTamIni := At(";",Substr(cMvTmsDoc,nPosIni)) - 1
			If nTamIni <= 0
		   		nTamIni := Len(Alltrim(Substr(cMvTmsDoc,nPosIni))) + 1
			EndIf
			AAdd( aRet, { 'B', Substr(cMvTmsDoc,nPosIni,nTamIni) })
		Else
			AAdd( aRet, { 'B', STR0106 + "1" }) //"Documento de Apoio 1"
		EndIf

		If ( nPosIni := At("C=",cMvTmsDoc)) <> 0
			nPosIni += 2
			nTamIni := At(";",Substr(cMvTmsDoc,nPosIni)) - 1
			If nTamIni <= 0
		   		nTamIni := Len(Alltrim(Substr(cMvTmsDoc,nPosIni))) + 1
			EndIf
			AAdd( aRet, { 'C', Substr(cMvTmsDoc,nPosIni,nTamIni) })
		Else
			AAdd( aRet, { 'C', STR0106 + "2" }) //"Documento de Apoio 2"
		EndIf
	EndIf

	AAdd( aRet, { 'D', STR0107 }) //"Nota Fiscal Reentrega"

	If !lRomaneio
		AAdd( aRet, { 'E', STR0108 }) //"CTRC Armazenagem"
		AAdd( aRet, { 'F', STR0109 }) //"Nota Fiscal Armazenagem"

		AAdd( aRet, { 'G', STR0110 }) //"Nota Fiscal Complemento"
	EndIf

	If lTmsCFec
		If ( nPosIni := At("H=",cMvTmsDoc)) <> 0
			nPosIni += 2
			nTamIni := At(";",Substr(cMvTmsDoc,nPosIni)) - 1
			If nTamIni <= 0
		   		nTamIni := Len(Alltrim(Substr(cMvTmsDoc,nPosIni))) + 1
			EndIf
			AAdd( aRet, { 'H', Substr(cMvTmsDoc,nPosIni,nTamIni) })
		Else
			AAdd( aRet, { 'H', STR0106 + "3" }) //"Documento de Apoio 3"
		EndIf

		If ( nPosIni := At("I=",cMvTmsDoc)) <> 0
			nPosIni += 2
			nTamIni := At(";",Substr(cMvTmsDoc,nPosIni)) - 1
			If nTamIni <= 0
		   		nTamIni := Len(Alltrim(Substr(cMvTmsDoc,nPosIni))) + 1
			EndIf
			AAdd( aRet, { 'I', Substr(cMvTmsDoc,nPosIni,nTamIni) })
		Else
			AAdd( aRet, { 'I', STR0106 + "4" }) //"Documento de Apoio 4"
		EndIf
	EndIf

	If !lRomaneio
		AAdd( aRet, { 'J', STR0175 }) //"CRT"

		AAdd( aRet, { 'K', STR0176 }) //"Carregamento em Partes"

		AAdd( aRet, { 'L', STR0177 }) //"CRT Complemento"

		AAdd( aRet, { 'M', STR0182 }) //"CTRC Anulacao"
	EndIf

	If lTmsCFec
		If ( nPosIni := At("N=",cMvTmsDoc)) <> 0
			nPosIni += 2
			nTamIni := At(";",Substr(cMvTmsDoc,nPosIni)) - 1
			If nTamIni <= 0
		   		nTamIni := Len(Alltrim(Substr(cMvTmsDoc,nPosIni))) + 1
			EndIf
			AAdd( aRet, { 'N', Substr(cMvTmsDoc,nPosIni,nTamIni) })
		Else
			AAdd( aRet, { 'N', STR0106 + "5" }) //"Documento de Apoio 5"
		EndIf

		If ( nPosIni := At("O=",cMvTmsDoc)) <> 0
			nPosIni += 2
			nTamIni := At(";",Substr(cMvTmsDoc,nPosIni)) - 1
			If nTamIni <= 0
		   		nTamIni := Len(Alltrim(Substr(cMvTmsDoc,nPosIni))) + 1
			EndIf
			AAdd( aRet, { 'O', Substr(cMvTmsDoc,nPosIni,nTamIni) })
		Else
			AAdd( aRet, { 'O', STR0106 + "6" }) //"Documento de Apoio 6"
		EndIf
	EndIf

	If !lRomaneio
		AAdd( aRet, { 'P', "CTRC Substituicao"	}) //"CTRC Anulacao"
	EndIf


	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DC5_DOCTMS', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := STR0111 //"Documento de Transporte Invalido !"
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf
	If	lTmDescri
		aRet2 := ExecBlock('TMDESCRI',.F.,.F.,{aRet})  	//Ponto de entrada que permite alterar a descricao.
		If ValType(aRet2) == "A"
			For nA := 1 To Len(aRet2)
				nPosDocto := AScan( aRet, {|x| x[1] == aRet2[nA,1]} )
				If nPosDocto <> 0
					aRet[nPosDocto,2] := aRet2[nA,2]
				EndIf
			Next nA
		EndIf
	EndIf

ElseIf 'TIPOCO' $ Upper( cCampo )

	lRet := .T.

	If !lTabDFI .Or. lFastAnytc //TMS
		AAdd( aRet, {'01', STR0112 }) //"Encerra Processo"
		AAdd( aRet, {'02', STR0113 }) //"Bloqueia Documento"
		AAdd( aRet, {'03', STR0114 }) //"Libera Documento"
		AAdd( aRet, {'04', STR0115 }) //"Retorna Documento"
		AAdd( aRet, {'05', STR0116 }) //"Informativa"
		If !__lPyme
			AAdd( aRet, {'06', STR0117 }) //"Gera Pendencia"
			AAdd( aRet, {'07', STR0118 }) //"Estorna Pendencia"
			AAdd( aRet, {'08', STR0119 }) //"Transferencia de Viagem"
			AAdd( aRet, {'09', STR0120 }) //"Gera Indenizacao"
			AAdd( aRet, {'10', STR0121 }) //"Estorna Indenização"
			AAdd( aRet, {'11', STR0122 }) //"Transferência de Mercadoria"
			AAdd( aRet, {'12', STR0123 }) //"Cancelamento"
			AAdd( aRet, {'13', STR0124 }) //"Chegada Eventual"
			AAdd( aRet, {'14', STR0168 }) //"Ajuste da Previsão de Chegada"

			//-- Rentabilidade de Ocorrências
			If DT2->(ColumnPos("DT2_CDPASR")) > 0
				AAdd( aRet, {'16', STR0334 }) //"Receita"
				AAdd( aRet, {'17', STR0335 }) //"Despesa"
				AAdd( aRet, {'18', STR0336 }) //"Receita/Despesa"
				AAdd( aRet, {'19', STR0337 }) //"Reentrega"
				AAdd( aRet, {'20', STR0338 }) //"Devolução"
				AAdd( aRet, {'21', STR0339 }) //"Entrega Trecho GFE"
			EndIf
		EndIf
	Else  //--OMS
		AAdd( aRet, {'04', STR0115 }) //"Retorna Documento"
		AAdd( aRet, {'15', STR0178 }) //"Devolucao de Documento"
	EndIf

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DT2_TIPOCO', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := STR0125 //'Tipo de ocorrencia invalida !'
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'TIPFAI' $ Upper( cCampo )

	lRet := .T.
	AAdd( aRet, {'01', STR0126 	}) //'Peso Mercadoria'
	AAdd( aRet, {'02', STR0127		}) //'Valor Mercadoria'
	AAdd( aRet, {'03', STR0128		}) //'Qtde. Volumes'
	AAdd( aRet, {'04', STR0129		}) //'Base RR'
	AAdd( aRet, {'05', STR0130		}) //'Qtde. Unitizador'
	AAdd( aRet, {'06', STR0131		}) //'Frete Despachante'
	AAdd( aRet, {'07', STR0132		}) //'Valor Informado'
	AAdd( aRet, {'08', STR0133		}) //'Km'

    // -- Verifica se utiliza modo express
    If lTMSExp
	    AAdd( aRet, {'09', 'Praca de Pedagio'     })
	EndIf
	AAdd( aRet, {'10', STR0151}) // Altura
	AAdd( aRet, {'11', STR0152}) // Largura
	AAdd( aRet, {'12', STR0153}) // Comprimento

	AAdd( aRet, {'13', STR0180}) // Dificuldade de acesso com base no total do frete sem imposto
	AAdd( aRet, {'14', STR0340}) // Com base no total do componente de frete sem imposto
	AAdd( aRet, {'15', STR0230}) //'Cliente Destinatário'

	If lCmpRatNew
		AAdd( aRet, {'16', STR0322}) //Herda Valor
		AAdd( aRet, {'17', STR0323}) //Taxa do Devedor por Lote
	EndIf

	If lNewTDA 
		AAdd( aRet, {'18', STR0377}) //TDA x Região
	EndIf 
	AAdd( aRet, {'51', 'Peso Transportado'    })
	AAdd( aRet, {'52', 'Qtde. Documentos'     })
	AAdd( aRet, {'53', 'Volume Transportado'  })
	AAdd( aRet, {'54', 'Diaria Semana'        })
	AAdd( aRet, {'55', 'Km'                   })
	AAdd( aRet, {'56', 'Pernoite'             })
	AAdd( aRet, {'57', 'Docto sem Imposto'    })
	AAdd( aRet, {'58', 'Docto com Imposto'    })
	AAdd( aRet, {'59', 'Qtde. de Entregas'    })
	AAdd( aRet, {'60', 'Diaria Fim de Semana' })
	AAdd( aRet, {'61', 'Valor Informado'      })
	AAdd( aRet, {'62', 'Peso Mercadoria'      })
	AAdd( aRet, {'63', 'Valor Mercadoria'     })
	AAdd( aRet, {'64', 'Qtde. Volumes'        })
	AAdd( aRet, {'65', 'Qtde. Unitizador'     })
	AAdd( aRet, {'66', 'Qtde. de Coletas'     })
	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DT3_TIPFAI', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := STR0143 //'Tipo de faixa invalida !'
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := PadR(aRet[ nX, 2 ],TamSX3(cCpoDes)[1])
					EndIf
					cDesc := PadR(aRet[ nX, 2 ],TamSX3("DT3_DESFAI")[1])
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'TIPNFC' $ Upper( cCampo )
	lRet := .T.
	AAdd( aRet, {'0', STR0286 	}) //'Normal'
	AAdd( aRet, {'1', STR0287 	}) //'Devolucao'
	AAdd( aRet, {'2', STR0288	}) //'SubContratacao'
	AAdd( aRet, {'3', STR0289	}) //'Nao Fiscal'
	AAdd( aRet, {'4', STR0290	}) //'Exportacao'
	AAdd( aRet, {'5', STR0291	}) //'Redespacho'
	AAdd( aRet, {'6', STR0292	}) //'Nao Fiscal 1'
	AAdd( aRet, {'7', STR0293	}) //'Nao Fiscal 2'
	AAdd( aRet, {'8', STR0294	}) //'Serv Vincul.Multimodal'
	AAdd( aRet, {'9', STR0295	}) //'Redespacho Intermediário'
	AAdd( aRet, {'A', STR0363   }) //'Vinc. Multimodal (Exped / Receb)'

	If !lArray
		If	lConsF3
			cTitulo := FWX3Titulo('DT3_DESTIP')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := STR0143 //'Tipo de faixa invalida !'
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := PadR(aRet[ nX, 2 ],TamSX3(cCpoDes)[1])
					EndIf
					cDesc := PadR(aRet[ nX, 2 ],TamSX3("DTC_DESTIP")[1])
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'TIPPND' $ Upper( cCampo )

	lRet := .T.
	AAdd( aRet, {'01', STR0154 }) //"Falta"
	AAdd( aRet, {'02', STR0155 }) //"Avaria"
	AAdd( aRet, {'03', STR0156 }) //"Sobra"
	AAdd( aRet, {'04', STR0183 }) //"Retorno Dc. Cliente"
	AAdd( aRet, {'05', STR0343 }) //"Retirada de mercadoria"
	AAdd( aRet, {'99', STR0157 }) //"Bloqueio"

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DT2_TIPOCO', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := STR0158 //'Tipo de Pendência Inválida !'
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'DT6_STATUS' $ Upper( cCampo )

	lRet := .T.
	AAdd( aRet, {"1", "Em Aberto"})
	AAdd( aRet, {"2", "Carregado"})
	AAdd( aRet, {"3", "Em Transito"})
	AAdd( aRet, {"4", "Chegada Parcial"})
	AAdd( aRet, {"5", "Chegada Final"})
	AAdd( aRet, {"6", "Indicado para Entrega"})
	AAdd( aRet, {"7", "Entregue"})
	AAdd( aRet, {"8", "Entregue Parcial"})
	AAdd( aRet, {"9", "Anulado"})
	AAdd( aRet, {"A", "Retorno Total"})
	AAdd( aRet, {"B", "Cancelamento SEFAZ Aguardando"})
	AAdd( aRet, {"C", "Cancelamento SEFAZ Autorizado"})
	AAdd( aRet, {"D", "Cancelamento SEFAZ Nao Autorizado"})
	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DT6_STATUS', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := 'Status Inválido !'
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'CODOPE' $ Upper( cCampo ) .Or. ('MV_PAR' $ Upper( cCampo ) .And. IsInCallStack("TMSA256") )

	lRet := .T.
	AAdd( aRet, { '01', 'REPOM TECNOLOGIA'	} )
	AAdd( aRet, { '02', 'POWERED BY PAMCARD'} )
	AAdd( aRet, { '03', 'PAG BEM'			} )

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DEG_CODOPE', 'X3Titulo()')
		Else
			If lValid
				If AllTrim( &(cCampo) ) == "02"
					lRet   := Pamcary()
				ElseIf AllTrim( &(cCampo) ) == "01" .OR. ( AllTrim( &(cCampo) ) == "03" .AND. !FwIsInCallStack("TMSA144") )
					lRet   := .T.
				ElseIf Empty(&(cCampo))
					lRet   := .T.
				Else
					cTexto := STR0162 //"Operadora de Frotas/Vale-Pedagio Invalida!"
					lRet   := .F.
					Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				EndIf

				If lRet .AND. cCampo == 'M->DEL_CODOPE' .AND. AllTrim( &(cCampo) ) == "03" .AND. FwIsInCallStack("OMS040VLD")
					Aviso( STR0089, STR0376, { STR0090 } ) //"AVISO"###"OK" "Para que a integração entre TMS Protheus e PAGBEM funcione corretamente, é necessario que o campo Telefone (DA4_TEL) seja informado com o Celular do Motorista e o campo DDD (DA4_DDD) seja preenchido."
				EndIf
			EndIf
			If lRet
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'ACAOTMS' $ Upper( cCampo )

	lRet := .T.
	AAdd( aRet, {'01', STR0218 }) //"Tracking"
	AAdd( aRet, {'02', STR0219 }) //"Cotação de Frete"
	AAdd( aRet, {'03', STR0220 }) //"Alterar Cotação de Frete"
	AAdd( aRet, {'04', STR0221 }) //"Cancelar Cotação de Frete"
	AAdd( aRet, {'05', STR0222 }) //"Confirmar Cotação de Frete"
	AAdd( aRet, {'06', STR0223 }) //"Histórico de Cotações de Frete"
	AAdd( aRet, {'07', STR0224 }) //"Solicitar Coleta"
	AAdd( aRet, {'08', STR0225 }) //"Alterar Solicitação de Coleta"
	AAdd( aRet, {'09', STR0226 }) //"Cancelar Solicitação de Coleta"
	AAdd( aRet, {'10', STR0227 }) //"Confirmar Solicitação de Coleta"
	AAdd( aRet, {'11', STR0228 }) //"Histórico de Solicitações de Coleta"

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'UQ_ACAOTMS', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := STR0229 //'Tipo de Ação Inválida !'
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'ACAO' $ Upper( cCampo )
	lRet := .T.
	AAdd( aRet, {'00', 'Nenhuma Acao' })
	AAdd( aRet, {'01', 'Registro de Ocorrencia' })
	AAdd( aRet, {'02', 'Movto. Custo de Transpote' })
	AAdd( aRet, {'03', 'Contrato Carret. Complementar' })

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DEM_ACAO', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := STR0170 //-- "Acao Invalida"
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'CPOMAC' $ Upper( cCampo )
	lRet := .T.
	AAdd( aRet, {'01', RetTitle('DTC_FILDOC') })
	AAdd( aRet, {'02', RetTitle('DTC_DOC'   ) })
	AAdd( aRet, {'03', RetTitle('DT6_QTDVOL') })
	AAdd( aRet, {'04', STR0231 })
	AAdd( aRet, {'05', RetTitle('DTC_FILIAL') })
	AAdd( aRet, {'06', RetTitle('DTQ_FILORI') })
	AAdd( aRet, {'07', RetTitle('DTQ_VIAGEM') })

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DAQ_CPOMAC', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(M->&(cCampo)) }) == 0
				cTexto := STR0232
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(M->&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf 'TIPLOG' $ Upper( cCampo )
	lRet := .T.
	AAdd( aRet, {'MT', 'Cadastro de Motoristas' })
	AAdd( aRet, {'VE', 'Cadastro de Veiculos' })
	AAdd( aRet, {'FR', 'Cadastro de Fornecedores' })
	AAdd( aRet, {'CC', 'Contrato de Carreteiro' })
	AAdd( aRet, {'QT', 'Quitacao de Contrato de Carreteiro' })
	AAdd( aRet, {'CV', 'Abertura de Controle de Viagem' })
	AAdd( aRet, {'BX', 'Baixa de Controle de Viagem' })
	AAdd( aRet, {'AV', 'Aviso de Pagamento de Postos' })
	AAdd( aRet, {'PP', 'Passagem em Postos' })
	AAdd( aRet, {'MV', 'Movimentacao de Valores' })
	AAdd( aRet, {'AC', 'Aviso de Pagamento de Carreteiros' })
	AAdd( aRet, {'AT', 'Solicitacao de Autorizacao para Quitacao do Contrato de Carreteiro' })
	AAdd( aRet, {'AP', 'Autorizacao de Pagamento de Saldo de Contrato' })

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DEO_TIPLOG', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := STR0172 //-- "Tipo de Log invalido!"
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'TIPPRI' $ Upper( cCampo ) .Or. 'MV_PAR' $ Upper( cCampo )

	lRet := .T.
	AAdd( aRet, {'01', STR0236 }) //"Perda de Agendamento"
	AAdd( aRet, {'02', STR0237 }) //"Data Atual"
	AAdd( aRet, {'03', STR0238 }) //"Data Futura"
	AAdd( aRet, {'04', STR0239 }) //"Sem Agendamento"

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DYK_TIPPRI', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := STR0240 //'Prioridade Inválida !'
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'CODPAR' $ Upper(cCampo)


	lRet := .T.
	//-- Tempo da jornada
	AAdd( aRet, {'J1', STR0246 })  //-- Tempo de entrada em descanso
	AAdd( aRet, {'J2', STR0247 })  //-- Tempo de descanso entre as jornadas
	AAdd( aRet, {'J3', STR0248 })  //-- Tempo de refeição
	AAdd( aRet, {'J4', STR0249 })  //-- Tempo da jornada de trabalho
	AAdd( aRet, {'J5', STR0260 })  //-- Tempo de viagens de longa distancia
	AAdd( aRet, {'J6', STR0250 })  //-- Tempo de descanso para viagens de longa distancia
	AAdd( aRet, {'J7', STR0251 })  //-- Tempo de descanso semanal para viagens de longa distancia
	AAdd( aRet, {'J8', STR0262 })  //-- Tempo permitido para direcao continua
	AAdd( aRet, {'J9', STR0263 })  //-- Tempo viagens semanais
	AAdd( aRet, {'JA', STR0278 })  //-- Tempo Descanso para viagens com distância continua
	//-- Tempo de permanencia
	AAdd( aRet, {'P1', STR0243 })  //-- Tempo de permanencia na filial de origem
	AAdd( aRet, {'P2', STR0244 })  //-- Tempo de permanencia na filial de transferencia
	AAdd( aRet, {'P3', STR0245 })  //-- Tempo de permanencia na filial de destino
	//-- Tempo de previsto X real
	AAdd( aRet, {'T1', STR0241})   //-- Tempo de tolerancia para sair da filial
	AAdd( aRet, {'T2', STR0242 })  //-- Tempo de tolerancia para chegar na filial
	AAdd( aRet, {'T3', STR0261 })  //-- Tempo de tolerancia de direcao continua

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DEY_CODPAR', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'APTJOR' $ Upper(cCampo)

	lRet := .T.

	AAdd( aRet, {'IJ', STR0252}) //-- Inicio Jornada
	AAdd( aRet, {'IV', STR0253}) //-- Inicio Viagem
	AAdd( aRet, {'IR', STR0254}) //-- Inicio Refeição
	AAdd( aRet, {'ID', STR0255}) //-- Inicio Descanso
	AAdd( aRet, {'IP', STR0296}) //-- Inicio Parada
	AAdd( aRet, {'IE', STR0349}) //-- Inicio Espera	
	AAdd( aRet, {'FE', STR0350}) //-- Fim Espera
	AAdd( aRet, {'FP', STR0297}) //-- Fim Parada
	AAdd( aRet, {'FD', STR0256}) //-- Fim Descanso
	AAdd( aRet, {'FR', STR0257}) //-- Fim Refeição
	AAdd( aRet, {'FV', STR0258}) //-- Fim Viagem
	AAdd( aRet, {'FJ', STR0259}) //-- Fim Jornada

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DEW_APTJOR', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'CRIRAT' $ Upper(cCampo) //Criterio Calculo Rateio

	lRet := .T.
	AAdd( aRet, {'1', STR0298 })  //1=Nao Utiliza
	AAdd( aRet, {'2', STR0299 })  //2=Orig/Dest
	AAdd( aRet, {'3', STR0300 })  //3=Maior Vlr.Comp
	AAdd( aRet, {'4', STR0301 })  //4=Maior Peso Real
	AAdd( aRet, {'5', STR0302 })  //5=Maior Peso M3
	AAdd( aRet, {'6', STR0303 })  //6=Maior Vlr.Merc
	AAdd( aRet, {'7', STR0304 })  //7=Maior Vol
	AAdd( aRet, {'8', STR0305 })  //8=Maior KM
	AAdd( aRet, {'9', STR0306 })  //9=Maior M3
	If lCmpRatNew
		AAdd( aRet, {'A', STR0319 })  //A=Orig/Dest Vge
		AAdd( aRet, {'B', STR0320 })  //B=Maior Peso Previsto
		AAdd( aRet, {'C', STR0321 })  //C=Maior Peso Previsto x Realizado
	EndIf
	AAdd( aRet, {' ', '     ' })  // Compatibilização Para Registros Antigos

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DUX_CRIRAT', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'PRORAT' $ Upper(cCampo)  //Criterio Rateio

	lRet := .T.

	AAdd( aRet, {'1', STR0298 })  //1=Nao Utiliza
	AAdd( aRet, {'2', STR0307 })  //2=Peso Real
	AAdd( aRet, {'3', STR0308 })  //3=Peso Cubado
	AAdd( aRet, {'4', STR0309 })  //4=M3
	AAdd( aRet, {'5', STR0310 })  //5=Volumes
	AAdd( aRet, {'6', STR0311 })  //6=Vlr.Merc
	AAdd( aRet, {'7', STR0312 })  //7=KM
	AAdd( aRet, {'8', STR0313 })  //8=Qtd.Doc.Cliente
	AAdd( aRet, {'9', STR0314 })  //9=Qtd.Doc.Transp
	If lCmpRatNew
		If !('DDC_PRORAT' $ Upper(cCampo))        //Nao Libera o tipo "A" para Negociação (DDC)
			AAdd( aRet, {'A', STR0315 })  //A=%Fixo
		EndIf
		AAdd( aRet, {'B', STR0316 })  //B=Peso Previsto
		AAdd( aRet, {'C', STR0317 })  //C=Peso PrevistoXRealizado
		AAdd( aRet, {'D', STR0318 })  //D=Qtd. Coletas
	EndIf
	AAdd( aRet, {' ', '     ' })  // Compatibilização Para Registros Antigos

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DUX_PRORAT', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf 'AGDENT' $ Upper(cCampo)

	lRet := .T.

	AAdd( aRet, {'1', STR0279})  	// "Em aberto"
	AAdd( aRet, {'2', STR0280}) 	// "Realizado"
	AAdd( aRet, {'3', STR0281}) 	// "Realizado com atraso"
	AAdd( aRet, {'4', STR0282}) 	// "Não atendido"
	AAdd( aRet, {'5', STR0283}) 	// "Aguardando Agd."
	AAdd( aRet, {'6', STR0284}) 	// "Cancelado"

ElseIf 'DUA_CODFOR' $ Upper(cCampo) .Or. 'DUA_LOJFOR' $ Upper(cCampo)

	lRet := .t.
	aRet := TmsFor2Vet() //-- Está No TMSXFUND

	//-- Ordena Vetor
	If Len(aRet) > 0
		aSort(aRet,,,{|x,y| x[1] < y[1] })
	EndIf

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'A2_COD', 'X3Titulo()')
		Else

			If cCampo == 'M->DUA_CODFOR'
				cCodFor:= M->DUA_CODFOR
				cLojFor:= Iif( !Empty( GDFieldGet('DUA_LOJFOR',n) ), GDFieldGet('DUA_LOJFOR',n), "" )
			ElseIf cCampo == 'M->DUA_LOJFOR'
				cCodFor:= Iif( !Empty( GDFieldGet('DUA_CODFOR',n) ), GDFieldGet('DUA_CODFOR',n), "" )
				cLojFor:= M->DUA_LOJFOR
			EndIf

			If lValid .And. !Empty(cCodFor + cLojFor) .And. Ascan( aRet, { |x| x[1] ==  ( cCodFor + '-' + cLojFor ) }) == 0
				Help('',1,'REGNOIS')
				lRet := .F.
			EndIf
		EndIf
	EndIf

ElseIf 'RATEIORENT' $ Upper(cCampo)

	lRet := .T.

	AAdd( aRet, {'1', STR0307 + " X " + STR0308  }) //-- Peso Real x Cubado
	AAdd( aRet, {'2', STR0307 })					//-- Peso Real
	AAdd( aRet, {'3', STR0308 })					//-- Peso Cubado
	AAdd( aRet, {'4', STR0346 })					//-- Valor
	AAdd( aRet, {'5', STR0310 })					//-- Volume
	AAdd( aRet, {'6', STR0347 })					//-- Quantidade

	If !lArray
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DUX_PRORAT', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf 'TIPOTRMS' $ Upper(cCampo) //--Tipo de Transmissão do MDF-e

	lRet := .T.

	AAdd( aRet, {'1', STR0352}) // Envio
	AAdd( aRet, {'2', STR0353}) //" Encerramento
	AAdd( aRet, {'3', STR0355}) //" Cancelamento
	AAdd( aRet, {'4', STR0354}) //" Consulta não encerrados
	AAdd( aRet, {'5', STR0356}) // "Inclusão de condutor
	AAdd( aRet, {'6', STR0357}) // Pagamento de Operação de Transporte

ElseIf 'ROTINA' $ Upper(cCampo)	//-- Automatização da Viagem

	lRet := .T.

	AAdd( aRet, {'TMSAF90', STR0358 })	//-- Carregamento da Viagem
	AAdd( aRet, {'TMSA310', STR0359 })	//-- Fechamento da Viagem
	AAdd( aRet, {'TMSA190', STR0360 })	//-- Manifesto
	AAdd( aRet, {'TMSA250', STR0361 })	//-- Contrato Carreteiro
	AAdd( aRet, {'TMSA340', STR0362 })	//-- Encerramento da Viagem

	If !lArray
		If Type("M->DMA_ROTINA") == "U"
			M->DMA_ROTINA := DMA_ROTINA
		EndIf
		If Type("M->DMB_ROTINA") == "U"
			M->DMB_ROTINA := DMB_ROTINA
		EndIf
		
		If	lConsF3
			cTitulo := My_Posicione('SX3', 2, 'DM9_ROTINA', 'X3Titulo()')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf

EndIf

If 'DTY_STATUS' $ Upper( cCampo )

	lRet := .T.
	AAdd( aRet, {"1", STR0364 }) //"Em Aberto"
	AAdd( aRet, {"2", STR0365 }) //"Aguard. Lib. p/ Pagto"
	AAdd( aRet, {"3", STR0366 }) //"Lib. p/ Pagto"
	AAdd( aRet, {"4", STR0367 }) //"Contr. Quit. com Ped. Compras"
	AAdd( aRet, {"5", STR0368 }) //"Contr. Quitado/Pagto. Realiz "
	AAdd( aRet, {"6", STR0369 }) //"Tit. Fatura "
	AAdd( aRet, {"7", STR0370 }) //"Aguardando Confirm. Webserver "
	AAdd( aRet, {"8", STR0371 }) //"Contrato Pago Pela Operadora. Aguard. Baixa Financeira. "
	AAdd( aRet, {"9", STR0372 }) //"Pagamento Bloqueado "
	AAdd( aRet, {"A", STR0373 }) //"Contr. Parcial/Pagto. Parcial "
	AAdd( aRet, {"B", STR0374 }) //"Contrato Quitado/Aguardando autorização Operadora "
	
	If !lArray
		If	lConsF3
			cTitulo := FWX3Titulo('DTY_STATUS')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) }) == 0
				cTexto := 'Status Inválido !'
				Aviso(STR0089, cTexto, {STR0090} ) //"AVISO"###"OK"
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
//-- Apresenta a tela para selecao do item.
If	lConsF3 .And. lRet

	If isInCallStack("TMSA296")
		Return aRet
	EndIf

	nTmsItem := TmsF3Array( {STR0013,STR0014}, aRet, cTitulo ) //"Codigo"###"Descricao"
	If	nTmsItem > 0

		//-- VAR_IXB eh utilizada como retorno da consulta F3 DLC.
		VAR_IXB := aRet[ nTmsItem, 1 ]

		//-- Grava Campo Loja Do Fornecedor
		If 'DUA_CODFOR' $ Upper(cCampo)
			GdFieldPut(	'DUA_LOJFOR', Substr(aRet[ nTmsItem, 1 ],TamSX3('DUA_CODFOR')[1] + 2,TamSX3('DUA_LOJFOR')[1]))
		EndIf
	Else
		lRet := .F.
		//-- Se variavel nao estiver inicializada e retornar NIL ocorre erro
		//-- Tratamento para retornar espaço em branco ao invés de NIL
		If VAR_IXB == NIL
			VAR_IXB := ""
		EndIf
	EndIf
EndIf

//-- Tipo do retorno da funcao
If lArray
	xRet := aRet
ElseIf lValid
	xRet := lRet
Else
	xRet := cDesc
EndIf
RestArea(aAreaDT2)
RestArea(aArea)
Return( xRet )
	
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSFretCar³ Autor ³ Antonio C Ferreira    ³ Data ³11.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtencao do Valor de Pedagio e Frete do Motorista.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSFretCar(ExpC1,ExpC2,ExpC3,ExpA1,ExpC4,ExpC5,ExpC6)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Rota da Viagem                                     ³±±
±±³          ³ ExpC2 = Proprietario  do Veiculo                           ³±±
±±³          ³ ExpC3 = Loja do Veiculo                                    ³±±
±±³			 ³ ExpA1 = Veiculos Relacionados                              ³±±
±±³			 ³ ExpC4 = Chave p/ procurar DTT                              ³±±
±±³			 ³ ExpC5 = Tipo de Servico                                    ³±±
±±³			 ³ ExpC6 = Tipo de Transporte                                 ³±±
±±³			 ³ ExpN1 = Peso do Documento                                  ³±±
±±³			 ³ ExpN2 = Peso Cubado do Documento                           ³±±
±±³			 ³ ExpC7 = Codigo da Operadora de Frotas/Vale-Pedagio         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSFretCar(cRotaVge, cCodFor, cLojFor, aVeiculos, cChave,;
                    cSerTms, cTipTra, nPesoDoc, nPesoM3Doc, cCodOpe, lCalcPdg,cTabCar,cTipOpVg,cFilOri,cViagem)

Local nA
Local nCapacMax   := 0
Local aRet        := {0,0,Space(Len(DVG->DVG_TABCAR)),.F.,{}}
Local cSeek       := ""
Local cRotaGen    := GetMv("MV_ROTGTAB",,"")  // Rota generica para tabela de frete de carreteiros
Local nValorFrete := 0
Local nTotDist    := 0
Local cTabFre     := ''
Local cTipTab     := ''
Local aContr      := {}
Local aTabCar     := {}
Local cChaveDTT   := ''
Local lFailPdg    := .F.
Local cCompCTC    := SuperGetMV('MV_COMPCTC',,.F.)
Local aVetAux     := {}
Local aFretAux    := {}
Local lTercRbq	  := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local aPtoDca	  := {}

Default cCodFor   := ""
Default cLojFor   := ""
Default aVeiculos := {}
Default cChave    := ""
Default cSerTMS   := ""
Default cTipTra   := ""
Default nPesoDoc  := 0
Default nPesoM3Doc:= 0
Default cCodOpe   := ''
Default lCalcPdg  := .T.
Default cTabCar   := Space(Len(DVG->DVG_TABCAR))
Default cTipOpVg  := ""
Default cFilOri   := M->DTR_FILORI  //Tratamento devido a Viagem Modelo 3 (DM4)
Default cViagem   := M->DTR_VIAGEM  //Tratamento devido a Viagem Modelo 3 (DM4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o Valor do Pedagio. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DA3->( DbSetOrder( 1 ) )
For nA := 1 to Len(aVeiculos)
	If DA3->( MsSeek( xFilial('DA3') + aVeiculos[nA,1], .F. ) )
		nCapacMax += DA3->DA3_CAPACM
	EndIf
Next nA

If lCalcPdg
	//-- Chama a rotina para calcular o valor do pedagio segundo a quantidade de eixo
	PamPtoDca(  , cFilOri, cViagem, aPtoDca )
	aRet[1] := TmsCalPdg(aVeiculos,cRotaVge,cCodOpe, @lFailPdg, aPtoDca)
Else
	aRet[1] := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem a Tabela de Frete.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA2->(DbSetOrder(1))  // A2_FILIAL+A2_COD+A2_LOJA
If SA2->( MsSeek(xFilial("SA2")+cCodFor+cLojFor) )
	//-- Busca Tabela de Carreteiro no contrato do Fornecedor
	aContr := TMSContrFor(SA2->A2_COD,SA2->A2_LOJA,,cSerTms,cTipTra,.F.,,cTipOpVg)
	If Len(aContr) > 0 .And. Empty(cTabCar)
		cTabFre := aContr[1,2] //--Tabela de Frete
		cTipTab := aContr[1,3] //--Tipo da Tabela
		cTabCar := aContr[1,4] //--Tabela Carreteiro
		If lTMTABCAR
			//-- P.E. que permite a troca da tabela de frete ou tabela por rota do carreteiro
			aTabCar := ExecBlock("TMTABCAR",.F.,.F., {cTabFre,cTipTab,cTabCar,cCodFor,cLojFor,cSerTms,cTipTra} )
			If ValType(aTabCar) == "A" .And. Len(aTabCar) == 3
				cTabFre := IIf( ValType(aTabCar[1]) == "C" , aTabCar[1] , cTabFre )
				cTipTab := IIf( ValType(aTabCar[2]) == "C" , aTabCar[2] , cTipTab )
				cTabCar := IIf( ValType(aTabCar[3]) == "C" , aTabCar[3] , cTabCar )
			EndIf
		EndIf
	Else
		cTabFre := ""
		cTipTab := ""
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a Tabela de Frete foi informada no Contrato de Fornecedor, o Cal-³
	//³culo do Frete sera feito na Geracao do Contrato de Carreteiro       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cTabFre)
		aRet[3] := cTabCar
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tabelas fora da vigencia e inativas nao poderao ser ajustadas      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DUS->(dbSetOrder(1))
		DUS->(MsSeek(xFilial('DUS')+aRet[3]))
		If (dDataBase < DUS->DUS_DATDE .Or. ;
			IIF(!Empty(DUS->DUS_DATATE),dDataBase > DUS->DUS_DATATE,.F.))
			Help("",1,"TMSXFUNA12" ) // A Tabela de Frete do Carreteiro esta fora de Vigencia ...
			Return( aRet )
		EndIf
		If !DTT->( MsSeek(cSeek := xFilial("DTT") + aRet[3] + cRotaVge ) )
			DTT->( MsSeek(cSeek := xFilial("DTT") + aRet[3] + cRotaGen ) )
		EndIf

		While DTT->( !Eof() .And. DTT_FILIAL+DTT_TABCAR+DTT_ROTA == cSeek )
			cChaveDTT := DTT->DTT_TIPVEI
			cChaveDTT += DTT->DTT_FRORB1
			cChaveDTT += DTT->DTT_FRORB2
			If lTercRbq
				cChaveDTT += Iif(Empty(DTT->DTT_FRORB3),StrZero(0,Len(DTT->DTT_FRORB3)),DTT->DTT_FRORB3)
			EndIf
			cChaveDTT += Iif(DTT->DTT_VEIRAS<>"3".And.!Empty(DTT->DTT_VEIRAS),DTT->DTT_VEIRAS,Substr(cChave,Len(cChave)-1,1))
			cChaveDTT += Iif(DTT->DTT_TIPVIA<>"0".And.!Empty(DTT->DTT_TIPVIA),DTT->DTT_TIPVIA,Substr(cChave,Len(cChave),1))

			If cChaveDTT == cChave
			   If (DTT->DTT_TIPCAL == "1")  // 1-Por Valor
				   aRet[2] += DTT->DTT_VALOR
				ElseIf (DTT->DTT_TIPCAL == "2")  // 2-Capacidade do Veiculo
				   aRet[2] += (DTT->DTT_VALOR / DTT->DTT_INTERV) * nCapacMax
				ElseIf (DTT->DTT_TIPCAL == "3")  // 3-Km
		         nTotDist    := TMSDistRot(cRotaVge)
		         nValorFrete := ( nTotDist * ( DTT->DTT_VALOR / DTT->DTT_INTERV ) )
		         If nValorFrete > 0
					   aRet[2] += nValorFrete
				   EndIf
				ElseIf (DTT->DTT_TIPCAL == "4")  // 4-Peso Documento
				   aRet[2] += (DTT->DTT_VALOR / DTT->DTT_INTERV) * nPesoDoc

			  		aVetAux := {}
			  		Aadd(aVetAux, {"",aRet[2],cCompCTC,0,0,aRet[2]})
			  		Aadd(aVetAux, {"",aRet[2],'TF',0,0,aRet[2]})
			  		AAdd(aFretAux,{"",aVetAux,cSerTms})
				ElseIf (DTT->DTT_TIPCAL == "5")  // 5-Peso Cubado Documento
					aRet[2] += (DTT->DTT_VALOR / DTT->DTT_INTERV) * nPesoM3Doc

					aVetAux := {}
			  		Aadd(aVetAux, {"",aRet[2],cCompCTC,0,0,aRet[2]})
			  		Aadd(aVetAux, {"",aRet[2],'TF',0,0,aRet[2]})
			  		AAdd(aFretAux,{"",aVetAux,cSerTms})
				EndIf
				//-- Executa Ponto de Entrada
				If lTMAFreCar
				   nValorFrete := ExecBlock("TMAFRECAR",.F.,.F.,{aRet[2]})
					If ValType(nValorFrete) <> "N"
						nValorFrete := 0
					EndIf
				   aRet[2] += nValorFrete
				EndIf
				Exit
			EndIf
			DTT->( DbSkip() )
		EndDo
	EndIf
EndIf
If Len(aFretAux) > 0
	aRet[5] := aFretAux[1]
EndIf

//-- Arredonda o Valor calculado do Frete conforme as configuracoes do campo
//-- DTR_VALFRE
aRet[2] := Round(aRet[2],TamSX3('DTR_VALFRE')[2])


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ESTRUTURA DO VETOR aRET                          ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aRet[1] - Valor do Pedagio                       ³
//³ aRet[2] - Valor do Frete                         ³
//³ aRet[3] - Tabela de Frete para Carreteiro        ³
//³ aRet[4] - .T. para Calculo de Pedagio efetuado   ³
//³            com sucesso (Operadoras de Frete)     ³
//³ aRet[5] - Vetor aFrete para Componente           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet[4] := lFailPdg

Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsXPesqui³ Autor ³ Richard Anderson      ³ Data ³12.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza pesquisa e retorna ao indice anterior a pesquisa   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsXPesqui()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsXPesqui()

Local nIndexOrd := IndexOrd()

AxPesqui()

DbSetOrder( nIndexOrd )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsSol   ³ Autor ³ Patricia A. Salomao   ³ Data ³04.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao no Cadastro de Solicitantes.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsSol()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsSol()

Local cCadastro := STR0144 //"Solicitantes"
Local aRotOld   := aClone(aRotina)
Local aCampos   := {}
Local cFiltro1  :=""
Local aRotina   := {}
Local nOrdDue   := DUE->(IndexOrd())
Local aPesq     := {}
Local cSeek     := ''
Local aAreaSIX  := SIX->( GetArea() )
Local lIncOld   := Inclui
Local lAltOld   := Altera

Private nOpcSel := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( xFilial('DUE') )
	AAdd( aCampos, 'DUE_FILIAL')
Else
	cSeek := xFilial('DUE')
EndIf
AAdd(aCampos, "DUE_CODSOL")
AAdd(aCampos, "DUE_NOME")

If Inclui .Or. Altera
	aRotina	:= {	{ STR0006 ,"TMSASolMnt",0,2},;	//"Visualizar"
					{ STR0145 ,"TMSASolMnt",0,3},;	//"Incluir"
					{ STR0146 ,"TMSASolMnt",0,4},;	//"Alterar"
					{ STR0147 ,"TMSASolMnt",0,5},;	//"Excluir"
					{ STR0148 ,"TMSConfSel",0,2,,,.T.} }	//"Confirmar"
Else
	aRotina	:= {	{ STR0006 ,"TMSASolMnt",0,2} }	//"Visualizar"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento na variavel aPesqui e cSeek da função MaWndBrowse para efetuar   ³
//³ a Pesquisa pela Filial                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SIX->( DbSetOrder(1) )
If SIX->( DbSeek( 'DUE' ) )
	While !SIX->( Eof() ) .And. SIX->INDICE == 'DUE'
		AAdd( aPesq, { If( !Empty(xFilial("DUE")), AllTrim(RetTitle("DUE_FILIAL")) + "+", "") + AllTrim(SIX->DESCRICAO), Val(SIX->ORDEM)} )
		SIX->( DbSkip() )
	End
EndIf


MaWndBrowse(0,0,300,662,cCadastro,"DUE",aCampos,aRotina,,cFiltro1,cFiltro1,.T.,,,aPesq,cSeek,,.F.)

Inclui := lIncOld
Altera := lAltOld
aRotina := aClone(aRotOld)
DUE->(DbSetOrder(nOrdDue))

RestArea( aAreaSIX )
Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsEndSol³ Autor ³ Patricia A. Salomao   ³ Data ³04.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao no Cadastro de Enderecos de Solicitantes.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsEndSol()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsEndSol(cAlias,cCodSol,cCliente,cLoja)

Local aRotOld   := aClone(aRotina)
Local cFiltro1  := ""
Local aCampos   := {}
Local aRotina   := {}
Local aRetPE    := {}

Default cCodSol := " "
Default cAlias  := "DT5"
Default cCliente:= " "
Default cLoja	:= " "

Private cCadastro := STR0149 //"Endereco de Solicitante e Cliente"
Private nOpcSel := 0

If ValType(cAlias) <> "C"
	cAlias := "DT5"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aCampos, "DUL_SEQEND")
AAdd(aCampos, "DUL_NOMRED")
AAdd(aCampos, "DUL_END")
AAdd(aCampos, "DUL_BAIRRO")
AAdd(aCampos, "DUL_MUN")
AAdd(aCampos, "DUL_EST")

aRotina	:= {	{ STR0006 ,"TMSASolMnt",0,2},;	//"Visualizar"
				{ STR0145 ,"TMSASolMnt",0,3},;	//"Incluir"
				{ STR0146 ,"TMSASolMnt",0,4},;	//"Alterar"
				{ STR0147 ,"TMSASolMnt",0,5},;	//"Excluir"
				{ STR0148 ,"TMSConfSel",0,2,,,.T.} }	//"Confirmar"

//-- Ponto de Entrada para permitir manipular botoes na pesquisa no Cadastro de Enderecos de Solicitantes (Solic.Coletas)
If ExistBlock("TMSENDSL")
	aRetPE := ExecBlock("TMSENDSL",.F.,.F.,{aRotina})
	If ValType(aRetPE)=="A" .And. Len(aRetPE) > 0
		aRotina := aClone(aRetPE)
	EndIf
EndIf

If !Empty(cCliente) .And. !Empty(cLoja)
	DUL->(DbSetOrder(2))
	cFiltro1 := '"'+xFilial("DUL")+cCliente+cLoja+'"''
ElseIf !Empty(cCodSol)
	cCodsol := &('M->'+cAlias+'_CODSOL')
	If !Empty(cCodsol)
		DUL->(DbSetOrder(3))
		cFiltro1 := '"'+xFilial("DUL")+cCodSol+'"''
	EndIf
EndIf

MaWndBrowse(0,0,300,662,cCadastro,"DUL",aCampos,aRotina,,cFiltro1,cFiltro1,.T.)

aRotina := aClone(aRotOld)

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSASolM³ Autor ³ Patricia A. Salomao   ³ Data ³ 04.07.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa Opcao Escolhida                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSASolMnt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias                                              ³±±
±±³          ³ ExpN1 = Registro                                           ³±±
±±³          ³ ExpN2 = Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSASolMnt(cAlias,nReg,nOpcx)

If	lVer811 .And. cAlias == 'DUE'
	Do Case
		Case nOpcx == 1
			FWExecView (, "TMSA440" , MODEL_OPERATION_VIEW , ,{|| .T. }, , , , , , , )
		Case nOpcx == 2
			FWExecView (, "TMSA440" , MODEL_OPERATION_INSERT , ,{|| .T. }, , , , , , , )
		Case nOpcx == 3
			FWExecView (, "TMSA440" , MODEL_OPERATION_UPDATE , ,{|| .T. }, , , , , , , )
		Case nOpcx == 4
			FWExecView (, "TMSA440" , MODEL_OPERATION_DELETE , ,{|| .T. }, , , , , , , )
	EndCase
Else
	RegToMemory(cAlias,nOpcx==3)
	Do Case
		Case nOpcx == 1
			AxVisual(cAlias,nReg,2)
		Case nOpcx == 2
			AxInclui(cAlias,nReg,3)
		Case nOpcx == 3
			AxAltera(cAlias,nReg,4)
		Case nOpcx == 4
			RegToMemory(cAlias,.F.) //Incluido para definir variaveis (M->) usadas no AxDeleta.
			AxDeleta(cAlias,nReg,5)
	EndCase
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsHrToInt³ Autor ³ Alex Egydio           ³ Data ³18.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Converte horas em inteiro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsHrToInt(cHora,nDigitos)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Hora                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsHrToInt(cHora,nDigitos)

Local nHoras
Local nMinutos
Local nQtDig

DEFAULT nDigitos := 3

cHora := StrTran(cHora,':','')

If Len(cHora) > 5 .And. nDigitos == 3
	nQtDig := Len(Left(cHora,(Len(cHora)-2)))
Else
	nQtDig := nDigitos
EndIf

nHoras    := Val(SubStr(cHora,1, nQtDig ))
nMinutos  := Val(SubStr(cHora,nQtDig+1,2))/60

Return( nHoras+nMinutos )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsPesoVge³ Autor ³Rodrigo de A Sartorio  ³ Data ³12.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna informacoes da viagem                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpA1:=TmsPesoVge(ExpC1,ExpC2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial da viagem                                   ³±±
±±³          ³ ExpC2 = Codigo da viagem                                   ³±±
±±³          ³ ExpA1 = Retorno da Viagem [1]Peso[2]Peso Cubado[3]Vlr Merca³±±
±±³                                      [4]Peso Estat [5]Peso Cubado Esta³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSPesoVge(cFilOri,cViagem)

Local cSeek:="",nPeso:=0,nPesoM3:=0,nValMerc:=0,nPesoEstat:=0,nPesoM3Est:=0
Local aArea:=GetArea()
Local aAreaDUD:=DUD->(GetArea())
Local aAreaDT6:=DT6->(GetArea())

DEFAULT cFilOri:= ""
DEFAULT cViagem:= ""

DUD->( DbSetOrder( 2 ) )
If DUD->( MsSeek( cSeek := xFilial('DUD') + cFilOri + cViagem, .F. ) )
	While DUD->( ! Eof() .And. DUD->DUD_FILIAL + DUD->DUD_FILORI + DUD->DUD_VIAGEM == cSeek )
		DT6->( DbSetOrder( 1 ) )
		If DT6->( ! MsSeek( xFilial('DT6') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE, .F. ) ) .Or. ;
			DUD->DUD_STATUS == StrZero( 4, Len( DUD->DUD_STATUS ) ) .Or. ; // Encerrado
			DUD->DUD_STATUS == StrZero( 9, Len( DUD->DUD_STATUS ) )        // Cancelado
			DUD->( DbSkip() )
			Loop
		EndIf
		nPeso    += DT6->DT6_PESO
		nPesoM3  += DT6->DT6_PESOM3
		nValMerc += DT6->DT6_VALMER
		// Soma o peso dos CTRCs DESCARREGADOS na filial atual
		If DUD->DUD_FILDCA == cFilAnt
			nPesoEstat += DT6->DT6_PESO
			nPesoM3Est += DT6->DT6_PESOM3
		EndIf
		DUD->( DbSkip() )
	EndDo
EndIf

RestArea(aArea)
RestArea(aAreaDUD)
RestArea(aAreaDT6)

Return {nPeso,nPesoM3,nValMerc,nPesoEstat,nPesoM3Est}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSDistRot³ Autor ³ Gilson da Silva       ³ Data ³19.02.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retornar o Total de Distancia da Rota                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSDistRot(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Rota da Viagem                                     ³±±
±±³          ³ ExpL1 - Exibe Help na Tela ?                               ³±±
±±³          ³ ExpC1 - Regiao Origem                                      ³±±
±±³          ³ ExpC2 - Regiao Destino                                     ³±±
±±³          ³ ExpC3 - Tipo de Transporte                                 ³±±
±±³          ³ ExpC4 - Cliente                                            ³±±
±±³          ³ ExpC5 - Loja                                               ³±±
±±³          ³ ExpL5 - Calcula Distancia Ida/Volta?                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Total de Distancia da Rota                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSDistRot(cRota, lHelp, cRegOri, cRegDes, cTipTra, cCliente, cLoja, lDistIV)

Local aArea       := GetArea()
Local aRet		   := {}  	// Array Que terá as Regiões dessa Rota
Local cCdrOri     := ''   	// Origem da Rota
Local cCdrDes     := '' 	// Destino da Rota
Local nTotDist    := 0     // Total da Distancia em KM entre a Região Origem e a região destino
Local nDist       := 0     // Distancia em KM entre a Região Origem e a região destino
Local nX          := 0     // Contador do For
Local nZ          := 0
Local ny          := 0
Local nW          := 0
Local aRegOriSup  := {}   // Grupo Cadastrado Acima da Regiao de Origem da Rota
Local aRegDesInf  := {}   // Grupo Cadastrado Abaixo da Regiao de Destino da Rota
Local aRegDesSup  := {}   // Grupo Cadastrado Acima da Regiao de Destino da Rota
Local lRet        := .F.
Local nDistRot    := 1		// 1 = localiza distancia por regiao ; 2 = localiza distancia 1o. por cliente e depois por regiao
Local nAdiDoc     := 0

Default cRota     := ''
Default lHelp     := .T.
Default cRegOri   := ''
Default cRegDes   := ''
Default cTipTra   := ''
Default cCliente  := ''
Default cLoja     := ''
Default lDistIV   := .F.

If Empty(DVA->(RecCount())) .And. Empty(DVZ->(RecCount()))
	Return nTotDist
EndIf
//-------------------------------------------------------------------------------------------
//- Quando Tipo De Operação Do Contrato é "Somente Coleta" Troca Reg. Destino Para MV_CDRORI
//-------------------------------------------------------------------------------------------
If IsInCallStack("TMSA460") //-- Verifica Se Utiliza Unidade De Negócios e Se Está Executando Solicitação De Coleta

	//-- Ajusta Variáveis Para Considerar DVZ Quando Necessário
	cTipTra := Iif(Empty(cTipTra),M->DT5_TIPTRA,cTipTra)

	If Empty(cCliente)
		If M->DT5_LOCCOL == '1' //-- Solicitante

			DbSelectArea("DUE")
			DbSetOrder(1) //-- DUE_FILIAL+DUE_CODSOL
			MsSeek( FWxFilial("DUE") + M->DT5_CODSOL , .F. )

			cCliente  := DUE->DUE_CODCLI
			cLoja     := DUE->DUE_LOJCLI
		Else	//-- Remetente
			cCliente  := M->DT5_CLIREM
			cLoja     := M->DT5_LOJREM
		EndIf
	EndIf

	//-- Verifica Se Os Elementos Para Cálculo Estão Informados
	If !Empty(M->DT5_NCONTR) .And. !Empty(M->DT5_CODNEG) .And. !Empty(M->DT5_SERVIC)

		//-- Determina Nova Região Conforme Operação No Contrato.
		If TmsSobServ('TIPOPE',.T.,.T.,M->DT5_NCONTR,M->DT5_CODNEG,M->DT5_SERVIC,"0",@nAdiDoc) == '1'	//-- '1' = Somente Coleta
			cRegDes := M->DT5_CDRDCA := SuperGetMV("MV_CDRORI",.F.,"")
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem as Regioes de Descarga da Rota                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cRota)
	aRet := TMSRegDca(cRota)
Else
	AAdd(aRet, { cRegOri, cRegDes } )
EndIf

If Len(aRet) > 0

	//-- Localiza distancia 1o. por cliente e depois por regiao
	If !Empty(cCliente) .And. !Empty(cLoja)
		nDistRot := 2
	EndIf

	For nW := 1 To nDistRot

		cCdrOri    := PadR(aRet[1][1],Len(DUY->DUY_GRPVEN)) // Regiao Origem da Rota

		aRegOriSup := TmsNivSup(cCdrOri) // Retorna o Grupo Cadastrado Acima da Regiao de Origem da Rota

		If !Empty(cRota)
			cTipTra := My_Posicione('DA8', 1, xFilial('DA8')+cRota, "DA8_TIPTRA")
		EndIf

		For nX := 1 To Len(aRet) // Regioes de Descarga

			cCdrDes := PadR(aRet[nX][2],Len(DUY->DUY_GRPVEN)) // Regiao Destino da Rota

			TmsNivInf( cCdrDes, @aRegDesInf ) // Retorna o Grupo Cadastrado Abaixo da Regiao Destino	da Rota

			For nZ := 1 To Len( aRegOriSup ) // Varia a Regiao de Origem

				//-- Procura a Distancia percorrida, variando entre a Distancia da Regiao de Origem e
				//-- todas as Regioes Cadastradas Abaixo da Regiao de Destino
				For nY := 1 To Len( aRegDesInf ) // Varia o Destino
					nDist := TmsTotDis(cCliente,cLoja,aRegOriSup[nZ],aRegDesInf[nY][1],cTipTra)
					nTotDist += nDist
					If !Empty(nDist)
						lRet     := .T.
						Exit
					EndIf
				Next nY

				//-- Se nao encontrou a Distancia percorrida, varia entre a Distancia da Regiao de Origem e
				//-- todas as Regioes Cadastradas Acima da Regiao de Destino
				If !lRet
					aRegDesSup := TmsNivSup(cCdrDes) // Grupo Abaixo da Regiao de Destino
					For nY := 1 To Len( aRegDesSup ) // Varia o Destino
						nDist := TmsTotDis(cCliente,cLoja,aRegOriSup[nZ],aRegDesSup[nY],cTipTra)
						nTotDist += nDist
						If !Empty(nDist)
							lRet     := .T.
							Exit
						EndIf
					Next nY
				EndIf

				If lRet
					Exit
				EndIf
			Next nZ

			If lRet
				cCdrOri    := PadR(aRet[nX][2],Len(DUY->DUY_GRPVEN))
				aRegOriSup := TmsNivSup(cCdrOri) // Grupo Acima da Regiao de Origem
				lRet       := .F.
			EndIf
		Next
		//-- Quando nao encontrar a distancia por cliente, zera a variavel para tentar localizar por regiao.
		If nTotDist == 0
			cCliente := ''
			cLoja    := ''
		Else
			Exit
		EndIf
	Next nW

	If lHelp .And. nTotDist == 0
		Help(' ', 1, 'TMSXFUNA28')			//-- Regiao nao encontrada no Cadastro de Distancias (DVA).
	EndIf
EndIf

If lDistIV
	nTotDist	:= nTotDist * 2
EndIf

RestArea( aArea )

Return( nTotDist )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSPesqBrw³ Autor ³ Patricia A. Salomao   ³ Data ³29.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pesquisa no ListBox (2a./3a. Coluna), os Valores digitados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSPesqBrw(ExpA1,ExpA2,ExpO1,ExpL1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array contendo os Itens do ListBox                  ³±±
±±³          ³ExpA2 - Array contendo os Titulos dos Itens do ListBox      ³±±
±±³          ³ExpO1 - Objeto do ListBox                                   ³±±
±±³          ³ExpL1 - Adiciona +1 na ordem de pesquisa do Vetor           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³Chamada pela Funcao TMSABrowse()                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsPesqBrw(aList, aTitulo, oLBx, lAdicOrd)

Local   cCampo	 := ''
Local   cOrd    := ''
Local   lSeek	 := .F.
Local   nOrdem	 := 1
Local   nSeek	 := 0
Local   oCbx    := {}
Local   oDlg    := {}
Local   oPsqGet := {}
Local   aCbx    := {}

Default aTitulo := {}
Default lAdicOrd:= .T.

//-- Retira elementos em branco
Aeval(aTitulo, { | e | Iif(!Empty(e),AAdd(aCbx,e),'') })

cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0016 //-- Pesquisa

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If	lSeek
	cCampo := AllTrim( cCampo )
	If lAdicOrd
		nOrdem += 1
	EndIf
	aSort( aList,,,{|x,y| x[nOrdem] < y[nOrdem]})
	nSeek := Ascan(aList, {|x| Iif( ValType(x[nOrdem]) == "N", cValToChar(x[nOrdem]) = AllTrim(cCampo) , x[nOrdem] = AllTrim(cCampo)  )  })
	If	nSeek > 0
		oLbx:nAT := nSeek
		oLbx:Refresh()
	EndIf
EndIf

oLbx:SetFocus()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSContrFor³ Autor ³ Eduardo de Souza     ³ Data ³ 03/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica o Contrato do Fornecedor                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSContrFor(ExpC1,ExpC2,ExpD1,ExpC3,ExpC4,ExpL1,ExpC5)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Fornecedor                                ³±±
±±³          ³ExpC2 - Loja do Fornecedor                                  ³±±
±±³          ³ExpD1 - DataBase                                            ³±±
±±³          ³ExpC3 - Tipo do servico                                     ³±±
±±³          ³ExpC4 - Tipo de Transporte                                  ³±±
±±³          ³ExpL1 - Valida se mostra Help, caso nao encontre o Contrato.³±±
±±³          ³ExpC5 - Tipo de Veiculo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo dados do Contrato:                           ³±±
±±³          ³        [01] - N.o do Contrato                              ³±±
±±³          ³        [02] - Tabela de Frete                              ³±±
±±³          ³        [03] - Tipo da Tabela de Frete                      ³±±
±±³          ³        [04] - Tabela de Carreteiro                         ³±±
±±³          ³        [05] - Gera Titulo de Pedagio (1=Sim / 2=Nao)       ³±±
±±³          ³        [06] - Deduz Valor do Pdg. do Frete (1=Sim / 2=Nao) ³±±
±±³          ³        [07] - Categoria da Tabela (1-Receber / 2-Pagar)    ³±±
±±³          ³        [08] - Gera Pedido de Compra (1=Sim / 2=Nao)        ³±±
±±³          ³        [09] - % Custo X Receita      			 		  ³±±
±±³          ³        [10] - Gera o Titulo de Frete Pós Ger.CTC			  ³±±
±±³          ³        [11] - Gera o título de pedágio já baixado          ³±±
±±³          ³        [12] - Informa se o PA gerado movimentará banco     ³±±
±±³          ³        [13] - Momento da Geração do Título de Adiantamento ³±±
±±³          ³        [14] - Ger.Tit.NDF pos Ger.CTC                      ³±±
±±³          ³        [15] - Momento da Geração do Título de Pedagio      ³±±
±±³          ³        [16] - Operação Junto a operadora de frota (repom)  ³±±
±±³          ³        [17] - % Adiantamento                               ³±±
±±³          ³        [18] - Abrangencia de Calculo                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSContrFor(cCodFor,cLoja,dData,cSerTms,cTipTra,lHelp,cTipVei,cTipOpVg,cFilOri,cViagem)

Local lAchou      := .F.
Local lForGen     := .F.
Local cForGen     := ""
Local aRetorno    := {}
Local cCatTab     := StrZero(2, Len(DTL->DTL_CATTAB)) // Categ. da Tabela : Frete a Pagar
Local cGerPC      := ''
Local lContinua   := .T.
Local cTitFrete   := ''
Local cBxTitPdg   := ''
Local cPaMovBco   := ''
Local cTitNDF     := ''
Local lPerCus     := DVG->(ColumnPos("DVG_PERCUS")) > 0
Local cMomGerAdi  := ''
Local cMomGerPDG  := ''
Local cOperac     := ''
Local nPerAdto    := 0
Local lTipOpVg    := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
Local lAbrCal     := DVG->(ColumnPos("DVG_ABRCAL")) > 0
Local lTipCal     := DVG->(ColumnPos("DVG_TIPCAL")) > 0
Local lCodReg     := DVG->(ColumnPos("DVG_CODREG")) > 0
Local aBaseContr  := {}

Default cCodFor   := ''
Default cLoja     := ''
Default dData     := dDataBase
Default cSerTms   := ''
Default cTipTra   := ''
Default lHelp     := .T.
Default cTipVei   := ''
Default cTipOpVg  := ''
Default cFilOri   := ""
Default cViagem   := ""

If lTMSBasCtr
	aBaseContr := ExecBlock("TMSBASCT",.F.,.F.,{cSerTms,cTipTra,cTipVei,cFilOri,cViagem})
	If ValType(aBaseContr) == "A" .And. Len(aBaseContr) == 3
		cSerTms := aBaseContr[1]
		cTipTra := aBaseContr[2]
		cTipVei := aBaseContr[3]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe contrato em vigencia para o fornecedor em questao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("DUJ")
DbSetOrder(2)
If DUJ->(MsSeek(xFilial("DUJ")+cCodFor+cLoja))
	While DUJ->(!Eof()) .And. DUJ->DUJ_FILIAL == xFilial("DUJ") .And. DUJ->DUJ_CODFOR + DUJ->DUJ_LOJFOR  == cCodFor + cLoja
		If Empty(DUJ->DUJ_FIMVIG) .Or. (DUJ->DUJ_INIVIG <= dData .And. DUJ->DUJ_FIMVIG >= dData)
			lAchou := .T.
			Exit
		EndIf
		DUJ->(DbSkip())
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao existir contrato em vigencia para o fornecedor em questao, verifica³
//³ se existe contrato em vigencia para o Fornecedor Generico (MV_FORGEN)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAchou
	cForGen := GetMV("MV_FORGEN")
	If DUJ->(MsSeek(xFilial("DUJ")+cForGen))
		While DUJ->(!Eof()) .And. DUJ->DUJ_FILIAL == xFilial("DUJ") .And. DUJ->DUJ_CODFOR + DUJ->DUJ_LOJFOR  == cForGen
			If Empty(DUJ->DUJ_FIMVIG) .Or. (DUJ->DUJ_INIVIG <= dData .And. DUJ->DUJ_FIMVIG >= dData)
				lAchou := .T.
				lForGen:= .T.
				Exit
			EndIf
			DUJ->(DbSkip())
		EndDo
	EnDif
EndIf

If lAchou
	lAchou := .F.
	DbSelectArea("DVG")
	DbSetOrder(1)
	If MsSeek(xFilial("DVG")+DUJ->DUJ_NCONTR)
		While DVG->(!Eof()) .And. DVG->DVG_FILIAL == xFilial("DVG") .And. DVG->DVG_NCONTR == DUJ->DUJ_NCONTR

			lContinua := .T.
			If (DVG->DVG_SERTMS == cSerTms) .And. (DVG->DVG_TIPTRA == cTipTra)

				//-- Verifica o tipo de veiculo informado no contrato
				If !Empty(DVG->DVG_TIPVEI) .AND. AllTrim(DVG->DVG_TIPVEI) <> AllTrim(cTipVei)
					lContinua := .F.
				EndIf

				If lContinua .And. lTipOpVg .And. AllTrim(DVG->DVG_TPOPVG) <> AllTrim(cTipOpVg)
					lContinua := .F.
				EndIf

				If lContinua
					lAchou := .T.

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³  Verifica o Criterio para Geracao do Pedido de Compra para o Fornecedor   ³
					//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
					//³ Caso o campo DUJ_GERAPC exista, a prioridade eh verificar o contrato      ³
					//³ do fornecedor.                                                            ³
					//³ As possibilidades para o campo sao:                                       ³
					//³ 1=Sim -> Gera o Pedido de Compra, independentemente do MV_TMSGRPC;        ³
					//³ 2=Nao -> Nao gera o Pedido de Compra, mesmo que o parametro MV_TMSGRPC    ³
					//³ esteja configurado como .T.;                                              ³
					//³ 3=Nao utiliza -> Nao utiliza o campo. Sera verificado o valor do parametro³
					//³ MV_TMSGRPC                                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cGerPC := DUJ->DUJ_GERAPC
					If Empty(cGerPC) .Or. cGerPC == '0'					
						cGerPC := IIf(GetMV('MV_TMSGRPC',,.F.), '1', '2')
					EndIf
					cTitFrete	:= IIf(DUJ->(ColumnPos('DUJ_TITFRE')) > 0,DUJ->DUJ_TITFRE,'')
					cBxTitPdg	:= IIf(DUJ->(ColumnPos('DUJ_BXAPDG')) > 0,DUJ->DUJ_BXAPDG,'')
					cPaMovBco	:= IIf(DUJ->(ColumnPos('DUJ_PAMOVB')) > 0,DUJ->DUJ_PAMOVB,'')
					cMomGerAdi	:= IIf(DUJ->(ColumnPos('DUJ_TITADI')) > 0,DUJ->DUJ_TITADI,'')
					cTitNDF		:= IIf(DUJ->(ColumnPos('DUJ_TITNDF')) > 0,DUJ->DUJ_TITNDF,'')
					cMomGerPDG	:= IIf(DUJ->(ColumnPos('DUJ_TITPDG')) > 0,DUJ->DUJ_TITPDG,'')
					cOperac   	:= IIf(DVG->(ColumnPos('DVG_OPERAC')) > 0,DVG->DVG_OPERAC,'')
					nPerAdto   	:= IIf(DUJ->(ColumnPos('DUJ_PERADT')) > 0,DUJ->DUJ_PERADT,'')
					AAdd( aRetorno, {	DUJ->DUJ_NCONTR,;
										DVG->DVG_TABFRE,;
										DVG->DVG_TIPTAB,;
										DVG->DVG_TABCAR,;
										DVG->DVG_TITPDG,;
										DVG->DVG_DEDPDG,;
										cGerPC,;
										DVG->DVG_GERTIT ,;
										Iif(lPerCus,DVG->DVG_PERCUS,0),;
										cTitFrete,;
										cbxTitPdg,;
										cPaMovBco,;
										cMomGerAdi,;
										cTitNDF	  ,;
										cMomGerPDG,;
										cOperac,;
										nPerAdto,;
										Iif(lAbrCal,DVG->DVG_ABRCAL,""),;
										Iif(lTipCal,DVG->DVG_TIPCAL,""),;
										If( lCodReg, DVG->DVG_CODREG, "" ) } )

					cCatTab := My_Posicione("DTL",1,xFilial("DTL")+DVG->DVG_TABFRE+DVG->DVG_TIPTAB,"DTL_CATTAB")
					If cCatTab == "1"
						cCatTab := "2"
					EndIf
					//-- Verifica se a tabela de frete esta ativa ou dentro da vigencia
					If ! TmsTbAtiva( DVG->DVG_TABFRE, DVG->DVG_TIPTAB, , , cCatTab )
						aRetorno := {}
					EndIf
				EndIf
			EndIf

			DVG->(DbSkip())
		EndDo
	EndIf
EndIf

If	!lAchou
	If lHelp
		Help('',1,'TMSXFUNA08FOR',,STR0342 + cCodFor + "/" + cLoja ,01,05,,,,,/*aSoluc*/) //| // "Contrato de fornecedor nao foi encontrado. Código: "...
	EndIf
EndIf

Return( aRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSCFec   ³ Autor ³ Robson Alves          ³ Data ³08.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Identifica se as funcionalidades de Carga Fechada estao     ³±±
±±³          ³ativas.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSCFec()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSCFec()

lTMSCFec := If(lTMSCFec==Nil,SuperGetMv("MV_TMSCFEC", .F., .F.) .Or. (nModulo<>43),lTMSCFec)

Return( lTMSCFec )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSDocXNf ³ Autor ³ Eduardo de Souza      ³ Data ³ 25/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Apresenta todas notas fiscais do documento.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSDocXNf(ExpC1,ExpC2,ExpC3)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial do Documento                                 ³±±
±±³          ³ExpC2 - Documento                                           ³±±
±±³          ³ExpC3 - Serie do Documento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSDocXNf(cFilDoc,cDocto,cSerie,cFilOri,cNumSol,lColeta)

Local cTitulo   := STR0005 // "Notas Fiscais do Documento"
Local cAlias    := If(FindFunction("TmsPsqDY4") .And. TmsPsqDY4(cFilDoc,cDocto,cSerie),"DY4","DTC")
Local cFiltro   := ""
Local aCampos   := {}
Local aArea	  	:= GetArea()
Local aOldRot   := Iif(Type('aRotina') == 'A',aRotina,{})
Local aRotina   := {}
Local aButTmp   := {}
Local aCores    := {}
Local aPesqui   := {}
Local cQuery	:= ""
Local oTempTable  	:= NIL
Local cAliasTRB 	:= CriaTrab(NIL,.F.)
Local lTMS3GFE  	:= Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local oStruct		:= Nil
Local aAuxAlias		:= {}
Local nCount		:= 1

Private cAliasTRB1	:= CriaTrab(NIL,.F.)
Private nOpcSel 	:= 0

Default lColeta 	:= .F.

AAdd( aRotina, { STR0006,"TMSViewNF",0,2} ) // "Visualizar"
If lTMS3GFE
	AAdd( aRotina, { STR0333,"TMSViewGFE",0,2} ) // "Docto de Carga (GFE)"
EndIf

//-- Ponto de Entrada permite manipular o Array de botoes na apresencao de todas as notas fiscais do documento.
If lTMSBUTNF
	aButTmp := ExecBlock('TMSBUTNF',.F.,.F.,{aRotina})
	If ValType(aButTmp)=='A' .And. Len(aButTmp) > 0
		aRotina := {}
		AEval(aButTmp,{|x,y| AAdd(aRotina,AClone(x)) })
	EndIf
EndIf

If cAlias == "DTC"

	oStruct		:= FWFormStruct( 1 , cAlias )
	aAuxAlias	:= oStruct:aFields

	For nCount := 1 To Len(aAuxAlias)
		If GetSX3Cache(aAuxAlias[nCount,1],'X3_BROWSE') == 'S'
			AAdd( aCampos, aAuxAlias[nCount,1])
		EndIf
	Next nCount

Else
	If cAlias == "DY4"

		Aadd(aCampos, { "DTC_FILORI"  , "C", TamSX3("DTC_FILORI")[1],0 } )
		Aadd(aCampos, { "DTC_LOTNFC"  , "C", TamSX3("DTC_LOTNFC")[1],0 } )
		Aadd(aCampos, { "DTC_DATENT"  , "D", TamSX3("DTC_DATENT")[1],0 } )
		Aadd(aCampos, { "DTC_NUMNFC"  , "C", TamSX3("DTC_NUMNFC")[1],0 } )
		Aadd(aCampos, { "DTC_SERNFC"  , "C", TamSX3("DTC_SERNFC")[1],0 } )
		Aadd(aCampos, { "DTC_EMINFC"  , "D", TamSX3("DTC_EMINFC")[1],0 } )
		Aadd(aCampos, { "DTC_QTDVOL"  , "N", TamSX3("DTC_QTDVOL")[1],0 } )
		Aadd(aCampos, { "DTC_PESO"    , "N", TamSX3("DTC_PESO")[1],0 } )
		Aadd(aCampos, { "DTC_VALOR"   , "N", TamSX3("DTC_VALOR")[1],0 } )
		Aadd(aCampos, { "DTC_CLIREM"  , "C", TamSX3("DTC_CLIREM")[1],0 } )
		Aadd(aCampos, { "DTC_LOJREM"  , "C", TamSX3("DTC_LOJREM")[1],0 } )
		Aadd(aCampos, { "DTC_NOMREM"  , "C", TamSX3("DTC_NOMREM")[1],0 } )
		Aadd(aCampos, { "DTC_CLIDES"  , "C", TamSX3("DTC_CLIDES")[1],0 } )
		Aadd(aCampos, { "DTC_LOJDES"  , "C", TamSX3("DTC_LOJDES")[1],0 } )
		Aadd(aCampos, { "DTC_NOMDES"  , "C", TamSX3("DTC_NOMDES")[1],0 } )
		Aadd(aCampos, { "DTC_FILDOC"  , "C", TamSX3("DTC_FILDOC")[1],0 } )
		Aadd(aCampos, { "DTC_DOC"  	  , "C", TamSX3("DTC_DOC")[1],0 } )
		Aadd(aCampos, { "DTC_SERIE"   , "C", TamSX3("DTC_SERIE")[1],0 } )
		Aadd(aCampos, { "DTC_DOCPER"  , "C", TamSX3("DTC_DOCPER")[1],0 } )
		Aadd(aCampos, { "DTC_CF"      , "C", TamSX3("DTC_CF")[1],0 } )
		Aadd(aCampos, { "DTC_EXCTDA"  , "C", TamSX3("DTC_EXCTDA")[1],0 } )
		Aadd(aCampos, { "DTC_VALICM"  , "N", TamSX3("DTC_VALICM")[1],0 } )
		Aadd(aCampos, { "DTC_NFELET"  , "C", TamSX3("DTC_NFELET")[1],0 } )
		Aadd(aCampos, { "DTC_EMINFE"  , "D", TamSX3("DTC_EMINFE")[1],0 } )
		Aadd(aCampos, { "DTC_CODNFE"  , "C", TamSX3("DTC_CODNFE")[1],0 } )
		Aadd(aCampos, { "DTC_BASICM"  , "N", TamSX3("DTC_BASICM")[1],0 } )
		Aadd(aCampos, { "DTC_BASESU"  , "N", TamSX3("DTC_BASESU")[1],0 } )
		Aadd(aCampos, { "DTC_VALIST"  , "N", TamSX3("DTC_VALIST")[1],0 } )
		Aadd(aCampos, { "DTC_NFEID"   , "C", TamSX3("DTC_NFEID")[1],0 } )
		Aadd(aCampos, { "DTC_MODELO"  , "C", TamSX3("DTC_MODELO")[1],0 } )
		Aadd(aCampos, { "DTC_SERDPC"  , "C", TamSX3("DTC_SERDPC")[1],0 } )
		Aadd(aCampos, { "DTC_TIPANT"  , "C", TamSX3("DTC_TIPANT")[1],0 } )
		Aadd(aCampos, { "DTC_ICMRET"  , "N", TamSX3("DTC_ICMRET")[1],0 } )
		Aadd(aCampos, { "DTC_CTEANT"  , "C", TamSX3("DTC_CTEANT")[1],0 } )
		Aadd(aCampos, { "DTC_DPCEMI"  , "D", TamSX3("DTC_DPCEMI")[1],0 } )
		Aadd(aCampos, { "DTC_NFENTR"  , "C", TamSX3("DTC_NFENTR")[1],0 } )
		Aadd(aCampos, { "DTC_IDREM"   , "C", TamSX3("DTC_IDREM")[1],0 } )
		Aadd(aCampos, { "DTC_SERVIC"  , "C", TamSX3("DTC_SERVIC")[1],0 } )
		Aadd(aCampos, { "DTC_CODPRO"  , "C", TamSX3("DTC_CODPRO")[1],0 } )
		Aadd(aCampos, { "LEG"  		  , "C", TamSX3("DTC_NFENTR")[1],0 } )

		/* Cria o arquivo de trabalho e seu primeiro indice. */
		oTempTable := FWTemporaryTable():New(cAliasTRB1)
		oTempTable:SetFields( aCampos )
		oTempTable:AddIndex("01", {"DTC_FILORI","DTC_LOTNFC","DTC_DATENT"} )
		oTempTable:Create()

		cQuery := " SELECT DTC.DTC_FILORI, DTC.DTC_LOTNFC, DTC.DTC_DATENT," + CRLF
		cQuery += "		   DTC.DTC_NUMNFC, DTC.DTC_SERNFC, DTC.DTC_EMINFC," + CRLF
		cQuery += "		   DTC.DTC_QTDVOL, DTC.DTC_PESO,   DTC.DTC_VALOR,"  + CRLF
		cQuery += "		   DTC.DTC_CLIREM, DTC.DTC_LOJREM, DTC.DTC_CODNFE," + CRLF
		cQuery += "		   DTC.DTC_CLIDES, DTC.DTC_LOJDES, DTC.DTC_NFEID,"  + CRLF
		cQuery += "		   DTC.DTC_FILDOC, DTC.DTC_DOC,    DTC.DTC_SERIE,"  + CRLF
		cQuery += "		   DTC.DTC_VALICM, DTC.DTC_NFELET, DTC.DTC_EMINFE," + CRLF
		cQuery += "		   DTC.DTC_BASICM, DTC.DTC_BASESU, DTC.DTC_VALIST," + CRLF
		cQuery += "		   DTC.DTC_MODELO, DTC.DTC_SERDPC, DTC.DTC_TIPANT,"  + CRLF
		cQuery += "		   DTC.DTC_CTEANT, DTC.DTC_DPCEMI, DTC.DTC_NFENTR," + CRLF
		cQuery += "		   DTC.DTC_EXCTDA, DTC.DTC_CF,     DTC.DTC_DOCPER," + CRLF
		cQuery += "		   DTC.DTC_SERVIC, DTC.DTC_CODPRO, DTC.DTC_ICMRET,"	+ CRLF
		cQuery += "		   DTC.DTC_IDREM, "	                                + CRLF
		cQuery += "		   SA11.A1_NOME NOMEREM, SA12.A1_NOME NOMEDES"  + CRLF

		cQuery += "   FROM " + RetSqlName("DT6") + " DT6 "                  + CRLF
		cQuery += "  INNER JOIN " + RetSqlName("DY4") + " DY4 " 			+ CRLF
		cQuery += "          ON DY4.DY4_FILIAL  = '" + xFilial("DY4") + "'" + CRLF
		cQuery += "		    AND DY4.DY4_FILDOC  = DT6_FILDOC "              + CRLF
		cQuery += "		    AND DY4.DY4_DOC		= DT6_DOC "                 + CRLF
		cQuery += "    	    AND DY4.DY4_SERIE	= DT6_SERIE "               + CRLF
		cQuery += "		    AND DY4.D_E_L_E_T_  = ' '"                      + CRLF
		cQuery += "  INNER JOIN " + RetSqlName("DTC") + " DTC "             + CRLF
		cQuery += "          ON DTC.DTC_FILIAL  = '" + xFilial("DTC") + "'" + CRLF
		cQuery += "		    AND DTC.DTC_FILORI	= DY4_FILORI "              + CRLF
		cQuery += "		    AND DTC.DTC_LOTNFC	= DY4_LOTNFC "              + CRLF
		cQuery += "		    AND DTC.DTC_NUMNFC	= DY4_NUMNFC "              + CRLF
		cQuery += "    	    AND DTC.DTC_SERNFC	= DY4_SERNFC "              + CRLF
		cQuery += "    	    AND DTC.DTC_CODPRO	= DY4_CODPRO "              + CRLF
		cQuery += "		    AND DTC.D_E_L_E_T_  = ' '"                      + CRLF
		cQuery += "  INNER JOIN " + RetSqlName("SA1") + " SA11 "            + CRLF
		cQuery += "          ON SA11.A1_FILIAL  = '" + xFilial("SA1") + "'" + CRLF
		cQuery += "    	    AND SA11.A1_COD	    = DTC_CLIREM "              + CRLF
		cQuery += "    	    AND SA11.A1_LOJA	= DTC_LOJREM "              + CRLF
		cQuery += "		    AND SA11.D_E_L_E_T_ = ' '"                      + CRLF
		cQuery += "  INNER JOIN " + RetSqlName("SA1") + " SA12 "            + CRLF
		cQuery += "          ON SA12.A1_FILIAL  = '" + xFilial("SA1")+ "'"  + CRLF
		cQuery += "         AND SA12.A1_COD     = DTC_CLIDES "              + CRLF
		cQuery += "         AND SA12.A1_LOJA	= DTC_LOJDES "              + CRLF
		cQuery += "         AND SA12.D_E_L_E_T_ = ' '"                      + CRLF
		cQuery += "  WHERE DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"  + CRLF
		cQuery += "    AND DT6.DT6_FILDOC = '" + cFilDoc        + "'"  + CRLF
		cQuery += "    AND DT6.DT6_DOC    = '" + cDocto         + "'"  + CRLF
		cQuery += "    AND DT6.DT6_SERIE  = '" + cSerie         + "'"  + CRLF
		cQuery += "    AND DT6.D_E_L_E_T_ = ' '"                       + CRLF

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)

		While (cAliasTRB)->(!Eof())
			RecLock(cAliasTRB1,.T.)
			(cAliasTRB1)->DTC_FILORI := (cAliasTRB)->DTC_FILORI
			(cAliasTRB1)->DTC_LOTNFC := (cAliasTRB)->DTC_LOTNFC
			(cAliasTRB1)->DTC_DATENT := STOD((cAliasTRB)->DTC_DATENT)
			(cAliasTRB1)->DTC_NUMNFC := (cAliasTRB)->DTC_NUMNFC
			(cAliasTRB1)->DTC_SERNFC := (cAliasTRB)->DTC_SERNFC
			(cAliasTRB1)->DTC_EMINFC := STOD((cAliasTRB)->DTC_EMINFC)
			(cAliasTRB1)->DTC_QTDVOL := (cAliasTRB)->DTC_QTDVOL
			(cAliasTRB1)->DTC_PESO   := (cAliasTRB)->DTC_PESO
			(cAliasTRB1)->DTC_VALOR  := (cAliasTRB)->DTC_VALOR
			(cAliasTRB1)->DTC_CLIREM := (cAliasTRB)->DTC_CLIREM
			(cAliasTRB1)->DTC_LOJREM := (cAliasTRB)->DTC_LOJREM
			(cAliasTRB1)->DTC_NOMREM := (cAliasTRB)->NOMEREM
			(cAliasTRB1)->DTC_CLIDES := (cAliasTRB)->DTC_CLIDES
			(cAliasTRB1)->DTC_LOJDES := (cAliasTRB)->DTC_LOJDES
			(cAliasTRB1)->DTC_NOMDES := (cAliasTRB)->NOMEDES
			(cAliasTRB1)->DTC_FILDOC := (cAliasTRB)->DTC_FILDOC
			(cAliasTRB1)->DTC_DOC    := (cAliasTRB)->DTC_DOC
			(cAliasTRB1)->DTC_SERIE  := (cAliasTRB)->DTC_SERIE
			(cAliasTRB1)->DTC_DOCPER := (cAliasTRB)->DTC_DOCPER
			(cAliasTRB1)->DTC_CF     := (cAliasTRB)->DTC_CF
			(cAliasTRB1)->DTC_EXCTDA := (cAliasTRB)->DTC_EXCTDA
			(cAliasTRB1)->DTC_VALICM := (cAliasTRB)->DTC_VALICM
			(cAliasTRB1)->DTC_NFELET := (cAliasTRB)->DTC_NFELET
			(cAliasTRB1)->DTC_EMINFE := STOD((cAliasTRB)->DTC_EMINFE)
			(cAliasTRB1)->DTC_CODNFE := (cAliasTRB)->DTC_CODNFE
			(cAliasTRB1)->DTC_BASICM := (cAliasTRB)->DTC_BASICM
			(cAliasTRB1)->DTC_BASESU := (cAliasTRB)->DTC_BASESU
			(cAliasTRB1)->DTC_VALIST := (cAliasTRB)->DTC_VALIST
			(cAliasTRB1)->DTC_NFEID  := (cAliasTRB)->DTC_NFEID
			(cAliasTRB1)->DTC_MODELO := (cAliasTRB)->DTC_MODELO
			(cAliasTRB1)->DTC_SERDPC := (cAliasTRB)->DTC_SERDPC
			(cAliasTRB1)->DTC_TIPANT := (cAliasTRB)->DTC_TIPANT
			(cAliasTRB1)->DTC_ICMRET := (cAliasTRB)->DTC_ICMRET
			(cAliasTRB1)->DTC_CTEANT := (cAliasTRB)->DTC_CTEANT
			(cAliasTRB1)->DTC_DPCEMI := STOD((cAliasTRB)->DTC_DPCEMI)
			(cAliasTRB1)->DTC_NFENTR := (cAliasTRB)->DTC_NFENTR
			(cAliasTRB1)->DTC_IDREM  := (cAliasTRB)->DTC_IDREM
			(cAliasTRB1)->DTC_SERVIC := (cAliasTRB)->DTC_SERVIC
			(cAliasTRB1)->DTC_CODPRO := (cAliasTRB)->DTC_CODPRO
			(cAliasTRB1)->LEG        := (cAliasTRB)->DTC_NFENTR

			MsUnlock()
			(cAliasTRB)->(DbSkip())
		EndDo
		(cAliasTRB)->(DbCloseArea())
		RestArea( aArea )

		aCampos := {}
		Aadd(aCampos, { "DTC_FILORI"  , PesqPict("DTC","DTC_FILORI"), RetTitle("DTC_FILORI"),TamSX3("DTC_FILORI")[1] } )
		Aadd(aCampos, { "DTC_LOTNFC"  , PesqPict("DTC","DTC_LOTNFC"), RetTitle("DTC_LOTNFC"),TamSX3("DTC_LOTNFC")[1] } )
		Aadd(aCampos, { "DTC_DATENT"  , PesqPict("DTC","DTC_DATENT"), RetTitle("DTC_DATENT"),TamSX3("DTC_DATENT")[1] } )
		Aadd(aCampos, { "DTC_NUMNFC"  , PesqPict("DTC","DTC_NUMNFC"), RetTitle("DTC_NUMNFC"),TamSX3("DTC_NUMNFC")[1] } )
		Aadd(aCampos, { "DTC_SERNFC"  , PesqPict("DTC","DTC_SERNFC"), RetTitle("DTC_SERNFC"),TamSX3("DTC_SERNFC")[1] } )
		Aadd(aCampos, { "DTC_EMINFC"  , PesqPict("DTC","DTC_EMINFC"), RetTitle("DTC_EMINFC"),TamSX3("DTC_EMINFC")[1] } )
		Aadd(aCampos, { "DTC_QTDVOL"  , PesqPict("DTC","DTC_QTDVOL"), RetTitle("DTC_QTDVOL"),TamSX3("DTC_QTDVOL")[1] } )
		Aadd(aCampos, { "DTC_PESO"    , PesqPict("DTC","DTC_PESO")	, RetTitle("DTC_PESO")	,TamSX3("DTC_PESO")[1] } )
		Aadd(aCampos, { "DTC_VALOR"   , PesqPict("DTC","DTC_VALOR")	, RetTitle("DTC_VALOR")	,TamSX3("DTC_VALOR")[1] } )
		Aadd(aCampos, { "DTC_CLIREM"   , PesqPict("DTC","DTC_CLIREM"), RetTitle("DTC_CLIREM"),TamSX3("DTC_CLIREM")[1] } )
		Aadd(aCampos, { "DTC_LOJREM"   , PesqPict("DTC","DTC_LOJREM"), RetTitle("DTC_LOJREM"),TamSX3("DTC_LOJREM")[1] } )
		Aadd(aCampos, { "DTC_NOMREM"   , PesqPict("DTC","DTC_NOMREM"), RetTitle("DTC_NOMREM"),TamSX3("DTC_NOMREM")[1] } )
		Aadd(aCampos, { "DTC_CLIDES"   , PesqPict("DTC","DTC_CLIDES"), RetTitle("DTC_CLIDES"),TamSX3("DTC_CLIDES")[1] } )
		Aadd(aCampos, { "DTC_LOJDES"   , PesqPict("DTC","DTC_LOJDES"), RetTitle("DTC_LOJDES"),TamSX3("DTC_LOJDES")[1] } )
		Aadd(aCampos, { "DTC_NOMDES"   , PesqPict("DTC","DTC_NOMDES"), RetTitle("DTC_NOMDES"),TamSX3("DTC_NOMDES")[1] } )
		Aadd(aCampos, { "DTC_FILDOC"   , PesqPict("DTC","DTC_FILDOC"), RetTitle("DTC_FILDOC"),TamSX3("DTC_FILDOC")[1] } )
		Aadd(aCampos, { "DTC_DOC"   	, PesqPict("DTC","DTC_DOC")	 , RetTitle("DTC_DOC"),TamSX3("DTC_DOC")[1] } )
		Aadd(aCampos, { "DTC_SERIE"   	, PesqPict("DTC","DTC_SERIE"), RetTitle("DTC_SERIE"),TamSX3("DTC_SERIE")[1] } )
		Aadd(aCampos, { "DTC_DOCPER"   	, PesqPict("DTC","DTC_DOCPER"), RetTitle("DTC_DOCPER"),TamSX3("DTC_DOCPER")[1] } )
		Aadd(aCampos, { "DTC_CF"   	, PesqPict("DTC","DTC_CF"), RetTitle("DTC_CF"),TamSX3("DTC_CF")[1] } )
		Aadd(aCampos, { "DTC_EXCTDA"   	, PesqPict("DTC","DTC_EXCTDA"), RetTitle("DTC_EXCTDA"),TamSX3("DTC_EXCTDA")[1] } )
		Aadd(aCampos, { "DTC_VALICM"   	, PesqPict("DTC","DTC_VALICM"), RetTitle("DTC_VALICM"),TamSX3("DTC_VALICM")[1] } )
		Aadd(aCampos, { "DTC_NFELET"   	, PesqPict("DTC","DTC_NFELET"), RetTitle("DTC_NFELET"),TamSX3("DTC_NFELET")[1] } )
		Aadd(aCampos, { "DTC_EMINFE"   	, PesqPict("DTC","DTC_EMINFE"), RetTitle("DTC_EMINFE"),TamSX3("DTC_EMINFE")[1] } )
		Aadd(aCampos, { "DTC_CODNFE"   	, PesqPict("DTC","DTC_CODNFE"), RetTitle("DTC_CODNFE"),TamSX3("DTC_CODNFE")[1] } )
		Aadd(aCampos, { "DTC_BASICM"   	, PesqPict("DTC","DTC_BASICM"), RetTitle("DTC_BASICM"),TamSX3("DTC_BASICM")[1] } )
		Aadd(aCampos, { "DTC_BASESU"   	, PesqPict("DTC","DTC_BASESU"), RetTitle("DTC_BASESU"),TamSX3("DTC_BASESU")[1] } )
		Aadd(aCampos, { "DTC_VALIST"   	, PesqPict("DTC","DTC_VALIST"), RetTitle("DTC_VALIST"),TamSX3("DTC_VALIST")[1] } )
		Aadd(aCampos, { "DTC_NFEID"   	, PesqPict("DTC","DTC_NFEID") , RetTitle("DTC_NFEID"),TamSX3("DTC_NFEID")[1] } )
		Aadd(aCampos, { "DTC_MODELO"   	, PesqPict("DTC","DTC_MODELO") , RetTitle("DTC_MODELO"),TamSX3("DTC_MODELO")[1] } )
		Aadd(aCampos, { "DTC_SERDPC"   	, PesqPict("DTC","DTC_SERDPC") , RetTitle("DTC_SERDPC"),TamSX3("DTC_SERDPC")[1] } )
		Aadd(aCampos, { "DTC_TIPANT"   	, PesqPict("DTC","DTC_TIPANT") , RetTitle("DTC_TIPANT"),TamSX3("DTC_TIPANT")[1] } )
		Aadd(aCampos, { "DTC_ICMRET"   	, PesqPict("DTC","DTC_ICMRET") , RetTitle("DTC_ICMRET"),TamSX3("DTC_ICMRET")[1] } )
		Aadd(aCampos, { "DTC_CTEANT"   	, PesqPict("DTC","DTC_CTEANT") , RetTitle("DTC_CTEANT"),TamSX3("DTC_CTEANT")[1] } )
		Aadd(aCampos, { "DTC_DPCEMI"   	, PesqPict("DTC","DTC_DPCEMI") , RetTitle("DTC_DPCEMI"),TamSX3("DTC_DPCEMI")[1] } )
		Aadd(aCampos, { "DTC_NFENTR"   	, PesqPict("DTC","DTC_NFENTR") , RetTitle("DTC_NFENTR"),TamSX3("DTC_NFENTR")[1] } )
		Aadd(aCampos, { "DTC_IDREM"   	, PesqPict("DTC","DTC_IDREM")  , RetTitle("DTC_IDREM"),TamSX3("DTC_IDREM")[1] } )
	EndIf
EndIf

If lColeta .And. cAlias == "DTC"
	DTC->(DbSetOrder(08))
	cFiltro := '"'+xFilial("DTC")+cFilOri+cNumSol+'"'
Else
	If FindFunction("TmsPsqDY4") .And. TmsPsqDY4(cFilDoc,cDocto,cSerie)
		(cAliasTRB1)->(DbGotop())
		If DTC->(FieldPos("DTC_NFENTR")) > 0
			aCores   := {}
			AAdd(aCores,{"(cAliasTRB1)->LEG == '1'" ,'BR_MARRON'	})	// -- Entregue
			AAdd(aCores,{"(cAliasTRB1)->LEG == '2'" ,'BR_VERDE'	})	//-- Nao entregue
			AAdd(aCores,{"(cAliasTRB1)->LEG == '3'" ,'BR_PINK'	})	//-- Bloqueado
			//MaWndBrowse(nLin1,nCol1,nLin2,nCol2,cTitle									  ,uAlias	 ,aCampos,aRotina,cFun,cTopFun,cBotFun,lCentered,aResource,nModelo,aPesqui,cSeek,lDic,lSavOrd,lParPad,lPesq,bViewReg,oBrowse)
			MaWndBrowse(0		,0		,300	,600 ,"Notas de Reent/Dev/Serv.Add.",cAliasTRB1,aCampos,aRotina,	 ,		  ,			,.T.		,		  ,		   ,aPesqui,""	,.F.,		  ,			,	  ,			 ,		  , , ,aCores)
		Else
			MaWndBrowse(0		,0		,300	,600 ,"Notas de Reent/Dev/Serv.Add.",cAliasTRB1,aCampos,aRotina,	 ,		  ,			,.T.		,		  ,		   ,aPesqui,""	,.F.)
		EndIf
	Else
		DTC->(DbSetOrder(3))
		cFiltro := '"'+xFilial("DTC")+cFilDoc+cDocto+cSerie+'"'
	EndIf
EndIf

If cAlias == "DTC"
	If DTC->(FieldPos("DTC_NFENTR")) > 0
		AAdd(aCores,{'DTC->DTC_NFENTR == "1"' ,'BR_MARRON'	})	// -- Entregue
		AAdd(aCores,{'DTC->DTC_NFENTR == "2"' ,'BR_VERDE'	})	//-- Nao entregue
		AAdd(aCores,{'DTC->DTC_NFENTR == "3"' ,'BR_PINK'	})	//-- Bloqueado
		MaWndBrowse(0,0,300,600,cTitulo,cAlias,aCampos,aRotina,,cFiltro,cFiltro,.T.,,,,,,,,.F.,,,,,aCores)
	Else
		MaWndBrowse(0,0,300,600,cTitulo,cAlias,aCampos,aRotina,,cFiltro,cFiltro,.T.)
	EndIf
EndIf

aRotina := aOldRot

Return( nOpcSel == 1 )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSViewNF
Tela de visualização da nota fiscal posicionada.
@type function
@author Eduardo de Souza
@version 12
@since 25/10/2004
@param [cAlias], Caracter, Alias
@param [nReg], Numérico, Posição do registro
@param [nOpcx], Numérico, Opção do aRotina
@return Nil Não há retorno
@obs Ajustado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 24/03/2017
/*/
//-------------------------------------------------------------------------------------------------
Function TMSViewNF(cAlias, nReg, nOpcx)

	Local aArea     := GetArea()
	Local aAreaDTC  := DTC->(GetArea())
	Local cCondicao := ""
	Local lTMS3GFE  := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)

	Default cAlias := ""
	Default nReg   := 0
	Default nOpcx  := 0

	dbSelectArea("DTC")

	If Type("aRotina") == "U"
		aRotina := {{"","",0,1,0,Nil},;
					{"","",0,2,0,Nil}}
	EndIf
	
	If lTMS3GFE .And. IsInCallStack("TMSDOCXNF")
		cAlias := "DTC"
	EndIf

	//-- Quando cAlias estiver informado (significa que a chamada foi realizada de um aRotina),
	//-- e todos os campos para busca do DTC pelo indice 1 existirem
	If ! Empty(cAlias) .And. (nOpcx == 4 .Or. nOpcx == 5)
		DTC->(dbSetOrder(1)) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC
		//-- Filtro para exibir os documentos do cliente conforme item posicionado na tela de detalhes
		cCondicao := "DTC_FILIAL = '" + xFilial("DTC")       + "' .And. "
		cCondicao += "DTC_FILORI = '" + (cAlias)->DTC_FILORI + "' .And. "
		cCondicao += "DTC_LOTNFC = '" + (cAlias)->DTC_LOTNFC + "' .And. "
		cCondicao += "DTC_CLIREM = '" + (cAlias)->DTC_CLIREM + "' .And. "
		cCondicao += "DTC_LOJREM = '" + (cAlias)->DTC_LOJREM + "' .And. "
		cCondicao += "DTC_CLIDES = '" + (cAlias)->DTC_CLIDES + "' .And. "
		cCondicao += "DTC_LOJDES = '" + (cAlias)->DTC_LOJDES + "' .And. "
		cCondicao += "DTC_SERVIC = '" + (cAlias)->DTC_SERVIC + "' .And. "
		cCondicao += "DTC_CODPRO = '" + (cAlias)->DTC_CODPRO + "'"

	Else

		DTC->(dbSetOrder(7)) //DTC_FILIAL+DTC_DOC+DTC_SERIE+DTC_FILDOC+DTC_NUMNFC+DTC_SERNFC
		//-- Filtro para exibir os documentos do cliente conforme item posicionado na tela de detalhes
		cCondicao := "DTC_FILIAL == '" + xFilial("DTC")    	+ "' .And. "
		cCondicao += "DTC_DOC    == '" + (cAlias)->(DTC_DOC)    + "' .And. "
		cCondicao += "DTC_SERIE  == '" + (cAlias)->(DTC_SERIE)  + "' .And. "
		cCondicao += "DTC_FILDOC == '" + (cAlias)->(DTC_FILDOC) + "' "

	EndIf

	Set Filter To &(cCondicao)
	DTC->(DbGoTop()) //-- Posiciona no primeiro registro considerando o filtro

	TmsA050Mnt("DTC", DTC->(Recno()), 2)
	dbClearFilter()

	RestArea(aAreaDTC)
	RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSConsDA8³ Autor ³ Richard Anderson      ³ Data ³ 04/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe browse das rotas com filtro                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSConsDA8()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsConsDA8()

Local cCadastro  := STR0150 //"Rotas"
Local aRotOld    := Iif( Type("aRotina") == "U",{},AClone(aRotina) ) 
Local aCampos    := {}
Local aIndexDA8  := {}
Local cFiltraDA8 := ''
Local bFiltraBrw := {}
Local nRecnoDA8  := 0
Local lAllRot    := .T.
Local cRotaDe    := Iif(Type("M->DTQ_ROTA") == "C",M->DTQ_ROTA,"")
Local cRotaAte   := Iif(!Empty(cRotaDe),Padr(AllTrim(cRotaDe),Len(M->DTQ_ROTA),"z"),"")
Local cSerTms    := Iif(Type("M->DTQ_SERTMS") == "C",M->DTQ_SERTMS,"")
Local cTipTra    := Iif(Type("M->DTQ_TIPTRA") == "C",M->DTQ_TIPTRA,"")
Local oModel     := FWModelActive()
Local oMdlGridDF8:= Nil
Local lAgdEntr   := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)
Local lVgeMod3   := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local oMdFldDTQ  := Nil

Local oMdFldDTP := Nil

Private nOpcSel  := 0

If oModel <> Nil .And. oModel:cID == 'TMSA146'  //--- Programacao de Carregamento
	oMdlGridDF8:= oModel:GetModel('MdGridDF8')

	cSerTms    := If( oMdlGridDF8:GetValue('DF8_SERTMS') == '1', '3', oMdlGridDF8:GetValue('DF8_SERTMS') )
	If Empty(cSerTms)
		cSerTms := FwFldGet('T01_SERTMS')
	EndIf
	cTipTra    := oMdlGridDF8:GetValue('DF8_TIPTRA')
ElseIf lVgeMod3	//-- Viagem Modelo 3
	oMdFldDTQ  := oModel:GetModel("MdFieldDTQ")
	cSerTms    := oMdFldDTQ:GetValue("DTQ_SERTMS")
	cTipTra    := oMdFldDTQ:GetValue("DTQ_TIPTRA")
	lAllRot    := .T.   
ElseIf oModel <> Nil .And. oModel:cID == 'TMSA170' .And. DTP->(ColumnPos("DTP_SERTMS")) > 0  //--- Lote de Notas Fiscais
	oMdFldDTP  := oModel:GetModel("MdFieldDTP")

	cSerTms    := oMdFldDTP:GetValue("DTP_SERTMS")
	cTipTra    := StrZero(1,Len(DTQ->DTQ_TIPTRA))
EndIf

If !Empty(cSerTms) .And. !Empty(cTipTra) .And. !lVgeMod3
	If cSerTms == StrZero(1,Len(DC5->DC5_SERTMS)) //-- Coleta
		If cTipTra == StrZero(1,Len(DC5->DC5_TIPTRA)) //-- Rodoviario
			Pergunte("TMA142",.F.)
		ElseIf cTipTra == StrZero(2,Len(DC5->DC5_TIPTRA)) //-- Aereo
			Pergunte("TMA143",.F.)
		EndIf
		lAllRot := (mv_par05 == 2) //-- Somente Rotas da Filial?
	ElseIf cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
		Pergunte("TMA144",.F.)
		lAllRot := (mv_par08 == 1) //-- Apresenta Todas Rotas?
	ElseIf cSerTms == StrZero(3,Len(DC5->DC5_SERTMS)) //-- Entrega

		If lAgdEntr
			Pergunte("TMSA141A",.F.)
		Else
			Pergunte("TMA141",.F.)
		EndIf

		lAllRot := (mv_par05 == 2) //-- Somente Rotas da Filial?
	EndIf
EndIf

aRotina := {}
AAdd( aRotina, { STR0001 ,"TMSConfSel",0,2,,,.T.} ) // "&Confirmar"

cFiltraDA8 := MntFilRot(cSerTMS,cTipTra,mv_par03, mv_par04,cRotaDe, cRotaAte, lallRot, lVgeMod3)

bFiltraBrw := {|| FilBrowse("DA8",@aIndexDA8,@cFiltraDA8) }
Eval(bFiltraBrw)

MaWndBrowse(0,0,300,600,cCadastro,"DA8",aCampos,aRotina,,,,.T.,,,,,,.F.)

nRecnoDA8 := DA8->(Recno())
aRotina   := AClone(aRotOld)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("DA8",aIndexDA8)

DA8->(dbGoTo(nRecnoDA8))

Return( nOpcSel == 1 )

//-- Utilizada para validar se o programa esta atualizado na chamada da TmsCalFret().
Function TMSXFUNAUPD()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsTotDis ³ Autor ³ Eduardo de Souza      ³ Data ³ 08/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a Distancia por Cliente/Regiao.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TmsTotDis(ExpC,ExpC2,ExpC3,ExpC4,ExpC5)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Cliente                                             ³±±
±±³          ³ExpC2 - Loja                                                ³±±
±±³          ³ExpC3 - Origem                                              ³±±
±±³          ³ExpC4 - Destino                                             ³±±
±±³          ³ExpC5 - Tipo Transporte                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSDistRot()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTotDis(cCliente,cLoja,cCdrOri,cCdrDes,cTipTra)

Local nTotDist := 0

If Empty(cCliente)
	//-- Distancias
	DVA->(DbSetOrder(1)) //DVA_FILIAL+DVA_CDRORI+DVA_CDRDES+DVA_TIPTRA
	If DVA->(MsSeek(xFilial("DVA") + cCdrOri + cCdrDes + cTipTra, .F.))
		nTotDist := DVA->DVA_KM
	EndIf
Else
	//-- Distancias por Cliente
	DVZ->(DbSetOrder(1)) //DVZ_FILIAL+DVZ_CODCLI+DVZ_LOJCLI+DVZ_CDORI+DVZ_CDRDES+DVZ_TIPTRA
	If DVZ->(MsSeek(xFilial("DVZ") + cCliente + cLoja + cCdrOri + cCdrDes + cTipTra, .F.))
		nTotDist := DVZ->DVZ_KM
	EndIf
EndIf

Return( nTotDist )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSFx2Aju ³ Autor ³ Eduardo de Souza      ³ Data ³ 04/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a valores da Sub-Faixa                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSFx2Aju()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias                                               ³±±
±±³          ³ExpC2 - Seek                                                ³±±
±±³          ³ExpB1 - While                                               ³±±
±±³          ³ExpN1 - Percentual de Ajuste                                ³±±
±±³          ³ExpN2 - Intervalo                                           ³±±
±±³          ³ExpL1 - Peso Real                                           ³±±
±±³          ³ExpN3 - Base Sub-Faixa                                      ³±±
±±³          ³ExpC3 - Tipo Sub-Faixa                                      ³±±
±±³          ³ExpN4 - Tamanho do campo Faixa                              ³±±
±±³          ³ExpC4 - Componente Peso Cobrado                             ³±±
±±³          ³ExpN5 - Peso Cobrado                                        ³±±
±±³          ³ExpC5 - Item da Sub-Faixa do Ajuste                         ³±±
±±³          ³ExpN6 - Valor da Sub-Faixa                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSFx2Aju(cAlias,cSeek,bWhile,nPerAju,nInterv,lPesoReal,nBaseCalFx2,;
cFaixa2,nLenTpFai,cPesCob,nPesoCob,cItemDW2,nRet)

Local nFaixa     := 0
Default cItemDW2 := ''

nPerAju := 0
nInterv := 0

If cAlias == "DW2"
	(cAlias)->(DbSetOrder(2))
Else
	(cAlias)->(DbSetOrder(1))
Endif

If	(cAlias)->(MsSeek(cSeek))
	While Eval(bWhile)
		//-- Analisa a faixa para obter o valor.
		nFaixa	:= 0
		If	cFaixa2 == StrZero( 1, nLenTpFai )         //-- Peso
			If	lPesoReal									     //-- Calculo pelo peso real
				nFaixa := (cAlias)->&(cAlias+"_VALATE") //-- Pegar a faixa peso
			Else												     //-- Calculo pelo peso cubado
				nFaixa := (cAlias)->&(cAlias+"_FATPES") //-- Pegar a faixa fator peso
			EndIf
		Else
		   nFaixa := (cAlias)->&(cAlias+"_VALATE")
		EndIf
		If	nBaseCalFx2 <= nFaixa
			//-- Componente de frete que determina o peso cobrado
			If	(cAlias)->&(cAlias+"_CODPAS") $ cPesCob
				nPesoCob := nBaseCalFx2
   		EndIf
			If cAlias == "DW2"
				nPerAju  := (cAlias)->&(cAlias+"_PERAJU")
				cItemDW2 := (cAlias)->&(cAlias+"_ITEM"  )
		   Else
			   nRet := (cAlias)->&(cAlias+"_VALOR" )
			EndIf
			nInterv := (cAlias)->&(cAlias+"_INTERV")
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSExp    ³ Autor ³ Rodrigo Gomes         ³ Data ³11/10/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Identifica se as funcionalidades de TMS Expess estao ativas.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSExp()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSExp()

lTMSExp := If(lTMSExp==Nil,SuperGetMv("MV_TMSEXP", .F., .F.),lTMSExp)

Return( lTMSExp )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSCalPdg ³ Autor ³ Rodrigo Gomes         ³ Data ³18/10/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o valor do pedagio, segundo a quantidade de eixo.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSCalPdg(ExpA1,ExpC1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo o veiculo e quantidade de eixo      ³±±
±±³          ³ ExpC1 = Rota da Viagem                                     ³±±
±±³          ³ ExpC2 = Codigo da Operadora de Frota/Vale-Pedagio          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TmsCalPdg(aVeiculos,cRotaVge,cCodOpe,lFailPdg,aPtoDca,cLotNfc,aPrcPdgOP)

Local nA       := 0
Local nRet     := 0
Local nRetPE   := 0
Local nQtdEix  := 0
Local nQtdEixV := 0
Local nQtdUti  := 0
Local cCodRod  := ""
Local cSeqPdg  := ""
Local aArea    := GetArea()
Local lTMSOPdg := SuperGetMV('MV_TMSOPDG',,'0') $ '1|2'
Local nQtTotEx := 0 //Total de Eixos dos veiculos da Viagem.
Local cCalPdg  := '1' //-- Calcula pedagio pela operadora
Local lTMVALPDG := Existblock('TMVALPDG')
Local lProcess	:= .F.
Local nValPdg  := 0
Local lSentid  := .T.

Default aVeiculos := {}
Default cCodOpe   := ''
Default cLotNfc	  := ''
Default aPtoDca   := {}
Default aPrcPdgOP := {}

lFailPdg := .F.
If !Empty(cCodOpe) .And. lDEGCalPdg
	cCalPdg := Posicione("DEG",1,xFilial("DEG")+cCodOpe,"DEG_CALPDG")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aVeiculos                                            ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aVeiculos[1] = Codigo do Veiculo                                      ³
//³ aVeiculos[2] = Quantidade de Eixo do Veiculo (DTR_QTDEIX)             ³
//³ aVeiculos[3] = Quantidade de Eixo do Veiculo na Volta (DTR_QTEIXV)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTMSOPdg .Or. Empty(cCodOpe) .Or. cCalPdg == "2" //-- Calcula o pedagio pelo Protheus
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o Valor do Pedagio. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DU0->(DbSetOrder(1)) //DU0_FILIAL+DU0_CODROD+DU0_SEQPDG
	DU2->(DbSetOrder(1)) //DU2_FILIAL+DU2_ROTA+DU2_CODROD+DU2_SEQPDG
	DA3->(DbSetOrder(1)) //DA3_FILIAL+DA3_COD
	DUT->(DbSetOrder(1)) //DUT_FILIAL+DUT_TIPVEI

	If Len(aVeiculos) > 0 .And. !Empty(aVeiculos[1][1])
		//-- Verifica Composição
		If !TMCOMPPDG(aVeiculos,cLotNfc,@nRet,cRotaVge,@aPrcPdgOP)
			For nA := 1 to Len(aVeiculos)
				If !Empty(Alltrim(aVeiculos[nA,1]))
					//-- Posiciona no cadastro de veiculos
					DA3->( MsSeek( xFilial('DA3') + aVeiculos[nA,1], .F. ) )
					//-- Posiciona no Cadastro de Tipos de Veiculos
					If DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
						//-- Nao considera Eixo para Utilitario
						If DUT->DUT_CATVEI <> '5'
							nQtdEix  += aVeiculos[nA,2] //-- Qtde. de Eixos (Ida)
							nQtdEixV += aVeiculos[nA,3] //-- Qtde. de Eixos (Volta)
						Else
							nQtdUti += 1
						EndIf
					EndIf
					lProcess := .T.
				EndIf
			Next nA

			If lProcess .AND. !Empty(cRotaVge)
				//-- Posiciona no cadastro de Rota X Rodovia
				DU2->( MsSeek(xFilial("DU2") + cRotaVge) )  // Posiciona na Rota
				While DU2->( !Eof() .And. DU2_ROTA == cRotaVge .And. DU2->DU2_FILIAL == xFilial("DU2"))
					cCodRod := DU2->DU2_CODROD
					cSeqPdg := DU2->DU2_SEQPDG
					nValPdg := 0
					// -- Posiciona no cadastro de pracas de pedagio para
					// -- obter o valor referente ao Eixo do Veiculo e Utilitarios
					If DU0->( MsSeek(xFilial("DU0") + cCodRod + cSeqPdg) )  // Posiciona nos Itens da Rodovia.
						If lSentid
							If DU2->DU2_SENTID == '1'//-- Somente Ida
								nRet += ( nQtdEix * DU0->DU0_VALEIX ) // Obtem o valor referente ao Eixo do Veiculo.
								nRet += ( nQtdUti * DU0->DU0_VALVEI ) // Obtem o valor para Utilitarios
								nValPdg := ( nQtdEix * DU0->DU0_VALEIX ) // Obtem o valor referente ao Eixo do Veiculo.
								nValPdg += ( nQtdUti * DU0->DU0_VALVEI ) // Obtem o valor para Utilitarios
								aAdd(aPrcPdgOP, {AllTrim(DU0->DU0_IOFPDG), nValPdg})
							ElseIf DU2->DU2_SENTID == '2' //-- Somente Volta
								nRet += ( nQtdEixV * DU0->DU0_VALEIX ) // Obtem o valor referente ao Eixo do Veiculo (Volta).
								nRet += ( nQtdUti * DU0->DU0_VALVEI ) // Obtem o valor para Utilitarios
								nValPdg := ( nQtdEixV * DU0->DU0_VALEIX ) // Obtem o valor referente ao Eixo do Veiculo (Volta).
								nValPdg += ( nQtdUti * DU0->DU0_VALVEI ) // Obtem o valor para Utilitarios
								aAdd(aPrcPdgOP, {AllTrim(DU0->DU0_IOFPDG), nValPdg})
							Else //-- Pedagio Ida/Volta
								nRet += ( (nQtdEix+nQtdEixV) * DU0->DU0_VALEIX ) // Obtem o valor referente ao Eixo do Veiculo (Ida/Volta).
								nRet += (( nQtdUti * DU0->DU0_VALVEI ) * 2) // Obtem o valor para Utilitarios
								nValPdg := ( (nQtdEix+nQtdEixV) * DU0->DU0_VALEIX ) // Obtem o valor referente ao Eixo do Veiculo (Ida/Volta).
								nValPdg += (( nQtdUti * DU0->DU0_VALVEI ) * 2) // Obtem o valor para Utilitarios
								aAdd(aPrcPdgOP, {AllTrim(DU0->DU0_IOFPDG), nValPdg})
							EndIf
						Else
							nRet += ( nQtdEix * DU0->DU0_VALEIX ) // Obtem o valor referente ao Eixo do Veiculo.
							nRet += ( nQtdUti * DU0->DU0_VALVEI ) // Obtem o valor para Utilitarios
							nValPdg := ( nQtdEix * DU0->DU0_VALEIX ) // Obtem o valor referente ao Eixo do Veiculo.
							nValPdg += ( nQtdUti * DU0->DU0_VALVEI ) // Obtem o valor para Utilitarios
							aAdd(aPrcPdgOP, {AllTrim(DU0->DU0_IOFPDG), nValPdg})
						EndIf
					EndIf
					DU2->( DbSkip() )
				EndDo
			EndIf
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o Valor do Pedagio da Operadora. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aVeiculos) > 0
		For nA := 1 to Len(aVeiculos)
			DA3->(DbSetOrder(1))
			If DA3->(MsSeek( xFilial('DA3') + aVeiculos[nA,1], .F. ) )
				DUT->( DbSetOrder( 1 ) )
				If DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
					//-- Nao considera Eixo para Utilitario
					If DUT->DUT_CATVEI <> '5'
						nQtdEix  += aVeiculos[nA,2] //-- Qtde. de Eixos (Ida)
						nQtdEixV += aVeiculos[nA,3] //-- Qtde. de Eixos (Volta)
						nQtTotEx += DA3->DA3_QTDEIX //Total de Eixos dos veiculos da Viagem.
					Else
						nQtdEix += 1
					EndIf
				EndIf
			EndIf
		Next nA

		If (nQtdEix + nQtdEixV) > 0
			//-- Realiza comunicacao com a Operadora
			CursorWait()
			MsgRun(	STR0166 + ' - ' + DA3->DA3_COD,; //-- "Calculando valor do Pedágio, por favor aguarde..."
					STR0165,; //-- "Aguarde a Comunicação com a Operadora"
					{|| nRet := TMSOperPdg(cCodOpe, cRotaVge, nQtdEix, nQtdeixV, nQtdUti, nQtTotEx, @lFailPdg, DA3->DA3_FROVEI, aPtoDca ) })
			CursorArrow()
		Else
			Help(" ",1,"TMSXFUNA46") //-- Calculo do pedágio não realizado -- Para viagens com Operadora de Frota, o cálculo do pedágio é baseado na quantidade de eixos do veículo e esta informação não está preenchida - VERIFIQUE.
		EndIf
	EndIf
EndIf

//-- permite efetuar o calculo do pedagio conforme valor especifico
If lTMVALPDG
	nRetPE := Execblock('TMVALPDG',.F.,.F.,{aVeiculos,cRotaVge,nRet}) // aVeiculos
	If ValType(nRetPE) == "N"
		nRet := nRetPE
	EndIf
EndIf

RestArea(aArea)
Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAgrRsc ³ Autor ³ Patricia A. Salomao   ³ Data ³ 07/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se tem Agravacao de Risco (DUW)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAgrRsc()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Tabela de Seguro                                    ³±±
±±³          ³ExpC2 - Tipo da Tabela de Seguro                            ³±±
±±³          ³ExpB1 - Componnente Seguro                                  ³±±
±±³          ³ExpN1 - Vetor contendo o documento                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSAgrRsc(cTabSeg,cTptSeg,cComSeg,aDoctos)
Local cAliasQry := GetNextAlias()
Local cQuery    := ''
Local aRet      := {}
Default cTabSeg := ''
Default cTptSeg := ''
Default cComSeg := ''
Default aDoctos := {'','','',0}

cQuery := " SELECT MIN(DUW_PERAGR) DUW_PERAGR "
cQuery += " FROM " + RetSqlName("DUW")
cQuery += " WHERE DUW_FILIAL = '" + xFilial("DUW") + "'"
cQuery += "   AND DUW_TABSEG = '" + cTabSeg + "'"
cQuery += "   AND DUW_TPTSEG = '" + cTptSeg + "'"
cQuery += "   AND DUW_COMSEG = '" + cComSeg + "'"
cQuery += "   AND DUW_VALATE >= " + AllTrim(Str(aDoctos[4]))
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If !(cAliasQry)->(Eof())
	AAdd(aRet, (cAliasQry)->DUW_PERAGR )
EndIf
dbCloseArea()

Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsPerCub ³ Autor ³ Eduardo de Souza      ³ Data ³ 24/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o percentual de cubagem                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsPerCub()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Produto                                            ³±±
±±³          ³ ExpC2 - Cliente                                            ³±±
±±³          ³ ExpC3 - Loja                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsPerCub(cCodPro,cCodCli,cLojCli)

Local nPerCub := 0
Local nRet    := 0
Default cCodCli := ''
Default cLojCli := ''

If !Empty(cCodCli) .And. !Empty(cLojCli)
	nPerCub := My_Posicione('SA7',1,xFilial("SA7")+cCodCli+cLojCli+cCodPro,'A7_PERCUB')
EndIf
If Empty(nPerCub)
	nPerCub := My_Posicione('SB5',1,xFilial('SB5')+cCodPro,'B5_PERCUB')
EndIf

//-- Manipula o percentual de cubagem.
If lTMPERCUB
	nRet := ExecBlock('TMPERCUB',.F.,.F.,{cCodPro,cCodCli,cLojCli})
	If ValType(nRet) == "N"
		nPerCub := nRet
	EndIf
EndIf

Return( nPerCub )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSVOdoEnt³ Autor ³ Richard Anderson      ³ Data ³ 16/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do Odometro do Veiculo - Entrada                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSVOdoEnt(cCodVei,nOdoEnt,nTipVei,lHelp,@nOdoSai,dDatRea) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Veiculo                                  ³±±
±±³          ³ ExpN2 - Valor do Odometro                                  ³±±
±±³          ³ ExpN3 - Tipo do Veiculo 0=Veic. 1=1oReb. 2=2oReb. 3=3oReb. ³±±
±±³          ³ ExpL4 - (.T.) Exibe o Help e (.F.) nao exibe o help        ³±±
±±³          ³ ExpN5 - Parametro a ser passado por referencia. Retorna a  ³±±
±±³          ³         ultima quilometragem de Saida do Veiculo           ³±±
±±³          ³ ExpN6 - Data da Realizacao da Viagem                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA350 / TMSA430 /TMSA310                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVOdoEnt(cCodVei,nOdoEnt,nTipVei,lHelp,nOdoSai,dDatRea)

Local   lRet      := .T.
Local   aArea     := GetArea()
Local   cQuery    := ""
Local   cAliasQry := ""
Local   lContVei  := SuperGetMv("MV_CONTVEI",,.T.)
Local   cDatSai   := ""
Local   cHorSai   := ""
Local   lVerData  := .F.
Local   lTMODOENT := ExistBlock("TMODOENT")
Local   lTMODOSAID:= ExistBlock("TMODOSAID")
Local   lTercRbq	:= DUV->(ColumnPos("DUV_CODRB3")) > 0

Default cCodVei   := ""
Default nOdoEnt   := 0
Default nTipVei   := 0 //-- Veiculo
Default lHelp     := .T.
Default dDatRea   := Ctod('')

If !Empty(dDatRea)
	lVerData := .T.
EndIf

Begin Sequence
//-- Se o campo de odometro dos reboques nao existirem, nao valida odometro dos reboques
If nTipVei > 0
	Break
EndIf
If lContVei
	//-- Retorna ultima data saida informada pra o veiculo
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(DTU_DATSAI) DTU_DATSAI "
	cQuery += " FROM " + RetSqlName("DTU") + " DTU "
	cQuery += " WHERE DTU_CODVEI  = '"+cCodVei+"'"
	cQuery += "   AND DTU_DATSAI <> ' '"
	cQuery += "   AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->DTU_DATSAI)
		cDatSai := (cAliasQry)->DTU_DATSAI
	EndIf
	(cAliasQry)->(dbCloseArea())
	//- Retorna ultima hora saida informada pra o veiculo
	cQuery := " SELECT MAX(DTU_HORSAI) DTU_HORSAI "
	cQuery += " FROM " + RetSqlName("DTU") + " DTU "
	cQuery += " WHERE DTU_CODVEI = '"+cCodVei+"'"
	cQuery += "   AND DTU_DATSAI = '"+cDatSai+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->DTU_HORSAI)
		cHorSai := (cAliasQry)->DTU_HORSAI
	EndIf
	(cAliasQry)->(dbCloseArea())
	//-- Retorna ultimo apontamento de saida informada pra o veiculo
	cQuery := " SELECT MAX(R_E_C_N_O_) NRECNO "
	cQuery += " FROM " + RetSqlName("DTU") + " DTU "
	cQuery += " WHERE DTU_CODVEI = '"+cCodVei+"'"
	cQuery += "   AND DTU_DATSAI = '"+cDatSai+"'"
	cQuery += "   AND DTU_HORSAI = '"+cHorSai+"'"
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->NRECNO)
		DTU->(MsGoTo((cAliasQry)->NRECNO))
		nOdoSai := DTU->DTU_ODOSAI
		//-- Necessario validar se o nOdoEnt < nOdoSai, mas nao trava, apenas informa.
		If !lHelp .And. nOdoEnt < nOdoSai
			If !( MsgNoYes( STR0159 + " Deseja Continuar ?.", STR0078 ) )		// "Atencao" ### "A quilometragem de entrada esta menor que a quilometragem da ultima saida."
				lRet := .F.
			EndIf
		EndIf
		If nOdoEnt < nOdoSai .And. lHelp
			If lTMODOSAID
				ExecBlock('TMODOSAID',.F.,.F.,{nOdoSai})
			Else
				Aviso(STR0078, STR0159 /*+ Chr(13) + STR0160 + Transform(DTU->DTU_ODOSAI, PesqPict("DUV", "DUV_ODOSAI"))*/, {"Ok"}) // "Atencao" ### "A quilometragem de entrada esta menor que a quilometragem da ultima saida."
			EndIf
			lRet := .F.
		Else
			If lVerData
				//-- Validar se a Data da Realizacao da Ocorrencia é Maior que a Data de Saida Veiculo
				If STOD(cDatSai) > dDatRea
					Aviso(STR0078, STR0173, {"Ok"}) // "Encontrado registro de saída para esse veículo com data maior que a data atual. Verifique a data de apontamento!"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
Else
	//-- Retorna ultima data saida informada pra o veiculo
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(DUV_DATSAI) DUV_DATSAI "
	cQuery += " FROM " + RetSqlName("DUV") + " DUV "
	cQuery += " WHERE DUV_DATSAI <> ' '"
	If nTipVei == 0 //-- Veiculo
		cQuery += " AND DUV_CODVEI = '"+cCodVei+"'"
	ElseIf nTipVei == 1 //-- 1o.Reboque
		cQuery += " AND DUV_CODRB1 = '"+cCodVei+"'"
	ElseIf nTipVei == 2 //-- 2o.Reboque
		cQuery += " AND DUV_CODRB2 = '"+cCodVei+"'"
	ElseIf nTipVei == 3 .And. lTercRbq //-- 3o.Reboque
		cQuery += " AND DUV_CODRB3 = '"+cCodVei+"'"
	EndIf
	cQuery += " AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->DUV_DATSAI)
		cDatSai := (cAliasQry)->DUV_DATSAI
	EndIf
	(cAliasQry)->(dbCloseArea())
	//- Retorna ultima hora saida informada pra o veiculo
	cQuery := " SELECT MAX(DUV_HORSAI) DUV_HORSAI "
	cQuery += " FROM " + RetSqlName("DUV") + " DUV "
	cQuery += " WHERE DUV_DATSAI = '" + cDatSai + "'"
	If nTipVei == 0 //-- Veiculo
		cQuery += " AND DUV_CODVEI = '"+cCodVei+"'"
	ElseIf nTipVei == 1 //-- 1o.Reboque
		cQuery += " AND DUV_CODRB1  = '"+cCodVei+"'"
	ElseIf nTipVei == 2 //-- 2o.Reboque
		cQuery += " AND DUV_CODRB2 = '"+cCodVei+"'"
	ElseIf nTipVei == 3 .And. lTercRbq //--3o.Reboque
		cQuery += " AND DUV_CODRB3 = '"+cCodVei+"'"
	EndIf
	cQuery += " AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->DUV_HORSAI)
		cHorSai := (cAliasQry)->DUV_HORSAI
	EndIf
	(cAliasQry)->(dbCloseArea())
	//-- Retorna ultimo apontamento de saida informada pra o veiculo
	cQuery := " SELECT MAX(R_E_C_N_O_) NRECNO "
	cQuery += " FROM " + RetSqlName("DUV") + " DUV "
	cQuery += " WHERE DUV_DATSAI = '"+cDatSai+"'"
	cQuery += "   AND DUV_HORSAI = '"+cHorSai+"'"
	If nTipVei == 0 //-- Veiculo
		cQuery += " AND DUV_CODVEI = '"+cCodVei+"'"
	ElseIf nTipVei == 1 //-- 1o.Reboque
		cQuery += " AND DUV_CODRB1  = '"+cCodVei+"'"
	ElseIf nTipVei == 2 //-- 2o.Reboque
		cQuery += " AND DUV_CODRB2 = '"+cCodVei+"'"
	ElseIf nTipVei == 3 .And. lTercRbq //-- 3o.Reboque
		cQuery += " AND DUV_CODRB3 = '"+cCodVei+"'"
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->NRECNO)
		DUV->(dbGoTo((cAliasQry)->NRECNO))
		If nTipVei == 0 //-- Veiculo
			nOdoSai := DUV->DUV_ODOSAI
		ElseIf nTipVei == 1 //-- 1o. Reboque
			nOdoSai := DUV->DUV_ODOSR1
		ElseIf nTipVei == 2 //-- 2o. Reboque
			nOdoSai := DUV->DUV_ODOSR2
		ElseIf nTipVei == 3 .And. lTercRbq //-- 3o. Reboque
			nOdoSai := DUV->DUV_ODOSR3
		EndIf
		//-- Necessario validar se o nOdoEnt < nOdoSai, mas nao trava, apenas informa.
		If !lHelp .And. nOdoEnt < nOdoSai
			If !( MsgNoYes( STR0159 + " Deseja Continuar ?.", STR0078 ) )		// "Atencao" ### "A quilometragem de entrada esta menor que a quilometragem da ultima saida."
				lRet := .F.
			EndIf
		EndIf
		If nOdoEnt < nOdoSai .And. lHelp
			If lTMODOSAID
				ExecBlock('TMODOSAID',.F.,.F.,{nOdoSai})
			Else
				Aviso(STR0078, STR0159 /*+ Chr(13) + STR0160 + Transform(nOdoSai, PesqPict("DUV", "DUV_ODOSAI"))*/, {"Ok"}) // "Atencao" ### "A quilometragem de entrada esta menor que a quilometragem da ultima saida."
			EndIf
			lRet := .F.
		Else
			If lVerData
				//-- Validar se a Data da Realizacao da Ocorrencia é Maior que a Data de Saida Veiculo
				If STOD(cDatSai) > dDatRea
					Aviso(STR0078, STR0173, {"Ok"}) // "Encontrado registro de saída para esse veículo com data maior que a data atual. Verifique a data de apontamento!"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
EndIf
End Sequence

If lRet .And. lTMODOENT
	lRet := ExecBlock('TMODOENT',.F.,.F.)
	If ValType(lRet) <> "L"
		lRet:= .T.
	EndIf
EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSVOdoSai³ Autor ³ Richard Anderson      ³ Data ³ 16/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do Odometro do Veiculo - Saida                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSVOdoSai(cCodVei,nOdoSai,nTipVei,lHelp,@nOdoEnt,dDatrea) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Veiculo                                  ³±±
±±³          ³ ExpN2 - Valor do Odometro                                  ³±±
±±³          ³ ExpN3 - Tipo do Veiculo 0=Veiculo 1=1oReb.2=2oReb. 3=3oReb.³±±
±±³          ³ ExpL4 - (.T.) Exibe o Help e (.F.) nao exibe o help        ³±±
±±³          ³ ExpN5 - Parametro a ser passado por referencia. Retorna a  ³±±
±±³          ³         ultima quilometragem de entrada do veiculo         ³±±
±±³          ³ ExpN6 - Data da Realizacao da Viagem                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA350 / TMSA430 /TMSA310                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVOdoSai(cCodVei,nOdoSai,nTipVei,lHelp,nOdoEnt,dDatRea)
Local   lRet      := .T.
Local   aArea     := GetArea()
Local   cQuery    := ""
Local   cAliasQry := ""
Local   lContVei  := SuperGetMv("MV_CONTVEI",,.T.)
Local   cDatEnt   := ""
Local   cHorEnt   := ""
Local   lVerData  := .F.
Local   lTMODOSAI := ExistBlock("TMODOSAI")
Local   lTMODOSAID:= ExistBlock("TMODOSAID")
Local   lTercRbq	:= DUV->(ColumnPos("DUV_CODRB3")) > 0

Default cCodVei   := ""
Default nOdoSai   := 0
Default nTipVei   := 0 //-- Veiculo
Default lHelp     := .T.
Default nOdoEnt   := 0
Default dDatRea   := Ctod('')

If !Empty(dDatRea)
	lVerData := .T.
EndIf

Begin Sequence
//- Se o campo de odometro dos reboques nao existirem, nao valida odometro dos reboques
If nTipVei > 0
	Break
EndIf
If lContVei
	//-- Retorna ultima data entrada informada pra o veiculo
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(DTU_DATENT) DTU_DATENT "
	cQuery += " FROM " + RetSqlName("DTU") + " DTU "
	cQuery += " WHERE DTU_CODVEI  = '" + cCodVei + "'"
	cQuery += "   AND DTU_DATENT <> ' '"
	cQuery += "   AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->DTU_DATENT)
		cDatEnt := (cAliasQry)->DTU_DATENT
	EndIf
	(cAliasQry)->(dbCloseArea())
	//-- Retorna ultima hora entrada informada pra o veiculo
	cQuery := " SELECT MAX(DTU_HORENT) DTU_HORENT "
	cQuery += " FROM " + RetSqlName("DTU") + " DTU "
	cQuery += " WHERE DTU_CODVEI = '" + cCodVei + "'"
	cQuery += "   AND DTU_DATENT = '" + cDatEnt + "'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->DTU_HORENT)
		cHorEnt := (cAliasQry)->DTU_HORENT
	EndIf
	(cAliasQry)->(dbCloseArea())
	//-- Retorna ultimo apontamento de entrada informada pra o veiculo
	cQuery := " SELECT MAX(R_E_C_N_O_) NRECNO "
	cQuery += " FROM " + RetSqlName("DTU") + " DTU "
	cQuery += " WHERE DTU_CODVEI = '" + cCodVei + "'"
	cQuery += "   AND DTU_DATENT = '" + cDatEnt + "'"
	cQuery += "   AND DTU_HORENT = '" + cHorEnt + "'"
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty( cDatEnt )
		DTU->(MsGoTo((cAliasQry)->NRECNO))
		nOdoEnt := DTU->DTU_ODOENT
		//-- Validar se utlimo apontamento de saida menor que apontamento de entrada informada.
		If !lHelp .And. nOdoSai < nOdoEnt
			If !( MsgNoYes( STR0159 + " Deseja Continuar ?.", STR0078 ) )		// "Atencao" ### "A quilometragem de entrada esta menor que a quilometragem da ultima saida."
				lRet := .F.
			EndIf
		EndIf
		If nOdoSai < nOdoEnt .And. lHelp
			If lTMODOSAID
				ExecBlock('TMODOSAID',.F.,.F.,{nOdoSai})
			Else
				If !( MsgNoYes( STR0161 + " Deseja Continuar ?.", STR0078 ) )	// "Atencao" ### "A quilometragem de saida está menor que a quilometragem da última entrada."
					lRet := .F.
				EndIf
			EndIf
		Else
			If lVerData
				//-- Validar se a Data da Realizacao da Ocorrencia é Maior que a Data de Saida Veiculo
				If STOD(cDatEnt) > dDatRea
					Aviso(STR0078, STR0173, {"Ok"}) // "Encontrado registro de entrada para esse veículo com data maior que a data atual. Verifique a data de apontamento!"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
Else
	//-- Retorna ultima data entrada informada pra o veiculo
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(DUV_DATENT) DUV_DATENT "
	cQuery += " FROM " + RetSqlName("DUV") + " DUV "
	cQuery += " WHERE DUV_DATENT <> ' '"
	If nTipVei == 0 //-- Veiculo
		cQuery += " AND DUV_CODVEI = '"+cCodVei+"'"
	ElseIf nTipVei == 1 //-- 1o.Reboque
		cQuery += " AND DUV_CODRB1 = '"+cCodVei+"'"
	ElseIf nTipVei == 2 //-- 2o.Reboque
		cQuery += " AND DUV_CODRB2  = '"+cCodVei+"'"
	ElseIf nTipVei == 3 .And. lTercRbq //--3o.Reboque
		cQuery += " AND DUV_CODRB3 = '"+cCodvei+"'"
	EndIf
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->DUV_DATENT)
		cDatEnt := (cAliasQry)->DUV_DATENT
	EndIf
	(cAliasQry)->(dbCloseArea())
	//-- Retorna ultima hora entrada informada pra o veiculo
	cQuery := " SELECT MAX(DUV_HORENT) DUV_HORENT "
	cQuery += " FROM " + RetSqlName("DUV") + " DUV "
	cQuery += " WHERE DUV_DATENT = '" + cDatEnt + "'"
	If nTipVei == 0 //-- Veiculo
		cQuery += " AND DUV_CODVEI = '"+cCodVei+"'"
	ElseIf nTipVei == 1 //-- 1o.Reboque
		cQuery += " AND DUV_CODRB1 = '"+cCodVei+"'"
	ElseIf nTipVei == 2 //-- 2o.Reboque
		cQuery += " AND DUV_CODRB2 = '"+cCodVei+"'"
	ElseIf nTipVei == 3 .And. lTercRbq //--3o.Reboque
		cQuery += " AND DUV_CODRB3 = '"+cCodvei+"'"
	EndIf
	cQuery += "   AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->DUV_HORENT)
		cHorEnt := (cAliasQry)->DUV_HORENT
	EndIf
	(cAliasQry)->(dbCloseArea())
	//-- Retorna ultimo apontamento de entrada informada pra o veiculo
	cQuery := " SELECT MAX(R_E_C_N_O_) NRECNO "
	cQuery += " FROM " + RetSqlName("DUV") + " DUV "
	cQuery += " WHERE DUV_DATENT = '"+cDatEnt+"'"
	If nTipVei == 0 //-- Veiculo
		cQuery += " AND DUV_CODVEI = '"+cCodVei+"'"
	ElseIf nTipVei == 1 //-- 1o.Reboque
		cQuery += " AND DUV_CODRB1 = '"+cCodVei+"'"
	ElseIf nTipVei == 2 //-- 2o.Reboque
		cQuery += " AND DUV_CODRB2 = '"+cCodVei+"'"
	ElseIf nTipVei == 3 .And. lTercRbq //--3o.Reboque
		cQuery += " AND DUV_CODRB3 = '"+cCodvei+"'"
	EndIf
	cQuery += "   AND DUV_HORENT = '"+cHorEnt+"'"
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	If !(cAliasQry)->(Eof()) .And. !Empty((cAliasQry)->NRECNO)
		DUV->(dbGoTo((cAliasQry)->NRECNO))
		If nTipVei == 0 //-- Veiculo
			nOdoEnt := DUV->DUV_ODOENT
		ElseIf nTipVei == 1 //-- 1o. Reboque
			nOdoEnt := DUV->DUV_ODOER1
		ElseIf nTipVei == 2 //-- 2o. Reboque
			nOdoEnt := DUV->DUV_ODOER2
		ElseIf nTipVei == 3 .And. lTercRbq //-- 3o. Reboque
			nOdoEnt := DUV->DUV_ODOER3
		EndIf
		//-- Validar se utlimo apontamento de saida menor que apontamento de entrada informada.
		If !lHelp .And. nOdoSai < nOdoEnt
			If !( MsgNoYes( STR0159 + " Deseja Continuar ?.", STR0078 ) )		// "Atencao" ### "A quilometragem de entrada esta menor que a quilometragem da ultima saida."
				lRet := .F.
			EndIf
		EndIf
		If nOdoSai < nOdoEnt .And. lHelp
			If lTMODOSAID
				ExecBlock('TMODOSAID',.F.,.F.,{nOdoSai})
			Else
				If !( MsgNoYes( STR0161 + " Deseja Continuar ?.", STR0078 ) )	// "Atencao" ### "A quilometragem de saida está menor que a quilometragem da última entrada."
					lRet := .F.
				EndIf
			EndIf
		Else
			If lVerData
				//-- Validar se a Data da Realizacao da Ocorrencia é Maior que a Data de Saida Veiculo
				If STOD(cDatEnt) > dDatRea
					Aviso(STR0078, STR0173, {"Ok"}) // "Encontrado registro de entrada para esse veículo com data maior que a data atual. Verifique a data de apontamento!"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
EndIf
End Sequence

If lRet .And. lTMODOSAI
	lRet := ExecBlock('TMODOSAI',.F.,.F.)
	If ValType(lRet) <> "L"
		lRet:= .T.
	EndIf
EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAtuMnt ³ Autor ³ Rodolfo K. Rosseto    ³ Data ³09.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao do Odometro, integracao com manutencao de ativos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cVeic - Codigo do Veiculo                                 ³±±
±±³          ³ cVeic1 - Codigo do Primeiro Reboque                        ³±±
±±³          ³ cVeic2 - Codigo do Segundo Reboque                         ³±±
±±³          ³ cVeic3 - Codigo do Terceiro Reboque                        ³±±
±±³          | nOdo1  - Numero do Odometro do Veiculo                     ³±±
±±³          | nOdo2  - Numero do Odometro do Primeiro Reboque            ³±±
±±³          | nOdo3  - Numero do Odometro do Segundo Reboque             ³±±
±±³          | nOdo4  - Numero do Odometro do Terceiro Reboque            ³±±
±±³          | nAcao 1- Montagem da Estrutura                             ³±±
±±³          |       2- Desmontagem da Estrutura                          ³±±
±±³          |       3- Aponta Contador                                   ³±±
±±³          |       4- Gera Ordem de Servico                             ³±±
±±³ 		 | aTrbEst - Array possuindo as tabelas temporárias de 		  ³±±
±±³ 		 		  	 estrutura do bem (SIGAMNT).					  ³±±
±±³					 [1] tabela temporaria do pai da estrutura - cTRBS    ³±±
±±³					 [2] tabela temporaria do pai da estrutura - cTRBF    ³±±
±±³					 [3] tabela temporaria do eixo suspenso    - CTRBEixo ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAtuMnt(cVeic,cVeic1,cVeic2,nOdo1,nOdo2,nOdo3,nAcao,dDatOdo,cHorOdo,lEstorno,cVeic3,nOdo4,aTrbEst)

Local aArea    := GetArea()
Local lMntTms  := (GetMV('MV_NGMNTMS',,'N') == 'S')	//Ativa integracao TMS X MNT
Local cCodBem  := ""
Local cBemFi1  := ""
Local cBemFi2  := ""
Local cBemFi3  := ""
Local lRet     := .T.
Local nTpCont  := 1
Local aRet1    := { .F., "" }
Local aRet2    := { .F., "" }
Local aRet3	 := { .F., "" }
Local cTMSREst := GetNewPar("MV_TMSREST","") //-- Código de Ocorrência para remover a estrutura
Local lGeraOs  := (GetMv("MV_NGGERPR",,"N") == "S") //-- Gera Ordem de Serviço MNT
Local cGERAPREV:= AllTrim(GETMv("MV_NGGERPR"))
Local lFi1CtPro:= .F.	//-- Informa se o 1o Reboque possui contador proprio
Local lFi2CtPro:= .F.	//-- Informa se o 2o Reboque possui contador proprio
Local lFi3CtPro:= .F.   //-- Informa se o 3o Reboque possui contador proprio
Local a470Info   := GetApoInfo( 'MNTA470.PRX' )
Local lFunCont := FindFunction("MntInfCnt")

Default dDatOdo		:= dDataBase
Default cHorOdo		:= Left(Time(),5)
Default cVeic		:= ""
Default cVeic1		:= ""
Default cVeic2		:= ""
Default cVeic3		:= ""
Default nOdo1		:= 0
Default nOdo2		:= 0
Default nOdo3		:= 0
Default nOdo4		:= 0
Default nAcao		:= 1
Default lEstorno	:= .F.
Default aTrbEst		:= {} //Variável criada para integração junto ao SIGAMNT

If lMntTms .And. !Empty(nOdo1)
	If DtoS( a470Info[4] ) + a470Info[5]  >= '2019052016:30:00'
		cCodBem := Posicione("DA3",1,xFilial("DA3")+cVeic,"DA3_CODBEM")
		cCodBem := PADR(cCodBem,Len(ST9->T9_CODBEM))

		If !Empty(cVeic1)
			cBemFi1  := Posicione("DA3",1,xFilial("DA3")+cVeic1,"DA3_CODBEM")
			cBemFi1  := PADR(cBemFi1,Len(ST9->T9_CODBEM))
			lFi1CtPro:= Posicione("ST9",1,xFilial("ST9")+cBemFi1,"T9_TEMCONT") == "S"
		EndIf

		If !Empty(cVeic2)
			cBemFi2  := Posicione("DA3",1,xFilial("DA3")+cVeic2,"DA3_CODBEM")
			cBemFi2  := PADR(cBemFi2,Len(ST9->T9_CODBEM))
			lFi2CtPro:= Posicione("ST9",1,xFilial("ST9")+cBemFi2,"T9_TEMCONT") == "S"
		EndIf

		If !Empty(cVeic3)
			cBemFi3  := Posicione("DA3",1,xFilial("DA3")+cVeic3,"DA3_CODBEM")
			cBemFi3  := PADR(cBemFi3,Len(ST9->T9_CODBEM))
			lFi3CtPro:= Posicione("ST9",1,xFilial("ST9")+cBemFi3,"T9_TEMCONT") == "S"
		EndIf

		If nAcao == 1 //-- Montagem da Estrutura

			If Empty(cBemFi1) .And. !Empty(cCodBem)
				If lEstorno
					MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
				Else
					If lFunCont
						lRet := MntInfCnt(cCodBem, dDatOdo, cHorOdo, nTpCont, nOdo1)
					Else
						NGTRETCON(cCodBem,dDatOdo,nOdo1,cHorOdo,nTpCont,{},.T.,,,,,aTrbEst)
					EndIf
					If lGeraOs .And. NGCONFOSAUT(cGERAPREV)
						NGGEROSAUT(DA3->DA3_CODBEM,nOdo1,,aTrbEst)
					EndIf
				EndIf
			EndIf

			If lRet .And. !Empty(cBemFi1) //1o Reboque

				If lEstorno //Estorno deleta movimentação do bem
					SomaDiaHor(@dDatOdo,@cHorOdo,HoraToInt("00:01"))//-- Soma um minuto no estorno para conflitar com o lancamento da desmontagem
					MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
					If	lFi1CtPro //Tem Contador Proprio
						MNT470EXCO(cBemFi1,dDatOdo,cHorOdo,1,aTrbEst)
					EndIf
					If	lFi2CtPro //Tem Contador Proprio
						MNT470EXCO(cBemFi2,dDatOdo,cHorOdo,1,aTrbEst)
					EndIf
					If	lFi3CtPro //Tem Contador Proprio
						MNT470EXCO(cBemFi3,dDatOdo,cHorOdo,1,aTrbEst)
					EndIf
				EndIf

				STC->(dbSetOrder(3))
				If STC->(!dbSeek(xFilial("STC")+cBemFi1+cCodBem)) //-- Verifica a existencia da estrutura
					//Monta a Estrutura incluindo o Primeiro Reboque.
					If lFi1CtPro
						aRet1 := NGESESTR(cCodBem,cBemFi1,nOdo2,dDatOdo,cHorOdo,nTpCont,"E",,,aTrbEst) //--Monta Estrutura com o contador do 1o Reboque
					ElseIf Posicione("ST9",1,xFilial("ST9")+cBemFi1,"T9_TEMCONT") == "P"
						aRet1 := NGESESTR(cCodBem,cBemFi1,nOdo1,dDatOdo,cHorOdo,nTpCont,"E",,,aTrbEst) //--Monta Estrutura com o contador do Pai da Estrutura
					EndIf
					If !aRet1[1]
						Help("",1,"TMSXFUNA40",,aRet1[2],3,1) //"Nao foi atualizado o Odometro do Bem"
					ElseIf lEstorno
						If lFi1CtPro //Estorno deleta movimentação do bem, gerada pela desmontagem da estrutura.
							MNT470EXCO(cBemFi1,dDatOdo,cHorOdo,1,aTrbEst)
						Else
							MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
						EndIf
					EndIf
				EndIf

			EndIf

			If lRet .And. !Empty(cBemFi2) //2o Reboque

				//Exclui movimento na STP pois será gerado um novo registro ao montar a estrutura
				If !lEstorno .And. aRet1[1]
					MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
				EndIf
				STC->(dbSetOrder(3))
				If STC->(!dbSeek(xFilial("STC")+cBemFi2+cCodBem))
					//Monta a Estrutura incluindo o Segundo Reboque .
					If lFi2CtPro
						aRet2 := NGESESTR(cCodBem,cBemFi2,nOdo3,dDatOdo,cHorOdo,nTpCont,"E",,,aTrbEst) //--Monta Estrutura com o contador do 2o Reboque
					Else
						aRet2 := NGESESTR(cCodBem,cBemFi2,nOdo1,dDatOdo,cHorOdo,nTpCont,"E",,,aTrbEst) //--Monta Estrutura com o contador do pai da estrutura
					EndIf
					If !aRet2[1]
						Help("",1,"TMSXFUNA40",,aRet2[2],3,1) //"Nao foi atualizado o Odometro do Bem"
					ElseIf lEstorno
						If lFi2CtPro
							MNT470EXCO(cBemFi2,dDatOdo,cHorOdo,1,aTrbEst)//Estorno deleta movimentação do bem, gerada pela desmontagem da estrutura.
						Else
							MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
						EndIf
					EndIf
				EndIf
			EndIf

			If lRet .And. !Empty(cBemFi2) .And. !lEstorno //-- Verifica a necessidade de atualização ST9/STP.
				If lFunCont
					lRet := MntInfCnt(cCodBem, dDatOdo, cHorOdo, nTpCont, nOdo1)
				Else
					NGTRETCON(cCodBem,dDatOdo,nOdo1,cHorOdo,nTpCont,{},.T.,,,,,aTrbEst)	//--Atualiza ST9, de acordo com o Odometro do Pai.
				EndIf
				If !aRet2[1] .And. lFi2CtPro //--Não foi montada a estrutura no momento da saida do veículo e Bem Possui contador Próprio
					If lFunCont
						lRet := MntInfCnt(cBemFi2, dDatOdo, cHorOdo, nTpCont, nOdo3)
					Else
						NGTRETCON(cBemFi2,dDatOdo,nOdo3,cHorOdo,nTpCont,{},.T.,,,,,aTrbEst) 	//--Atualiza ST9, de acordo com o Odometro Próprio.
					EndIf
				EndIf
			EndIf

			If lRet .And. !Empty(cBemFi3) //3o Reboque

				//Exclui movimento na STP pois será gerado um novo registro ao montar a estrutura
				If !lEstorno .And. aRet1[1]
					MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
				EndIf
				STC->(dbSetOrder(3))
				If STC->(!dbSeek(xFilial("STC")+cBemFi3+cCodBem))
					//Monta a Estrutura incluindo o Terceiro Reboque .
					If lFi3CtPro
						aRet3 := NGESESTR(cCodBem,cBemFi3,nOdo1,dDatOdo,cHorOdo,nTpCont,"E",,,aTrbEst) //--Monta Estrutura com o contador do 3o Reboque
						If lFunCont
							lRet := MntInfCnt(cBemFi2, dDatOdo, cHorOdo, nTpCont, nOdo4)
						Else
							NGTRETCON(cBemFi2,dDatOdo,nOdo4,cHorOdo,nTpCont,{},.T.,,,,,aTrbEst)//-- Apontado contador para o FIlho da estrutura
						EndIf
					Else
						aRet3 := NGESESTR(cCodBem,cBemFi3,nOdo1,dDatOdo,cHorOdo,nTpCont,"E",,,aTrbEst) //--Monta Estrutura com o contador do pai da estrutura
					EndIf
					If !aRet3[1]
						Help("",1,"TMSXFUNA40",,aRet3[2],3,1) //"Nao foi atualizado o Odometro do Bem"
						lRet := .F.
					ElseIf lEstorno
						If lFi3CtPro
							MNT470EXCO(cBemFi3,dDatOdo,cHorOdo,1,aTrbEst)//Estorno deleta movimentação do bem, gerada pela desmontagem da estrutura.
						Else
							MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
						EndIf
					EndIf
				EndIf
			EndIf

			If lRet .And. !Empty(cBemFi3) .And. !lEstorno //-- Verifica a necessidade de atualização ST9/STP.
				If lFunCont
					lRet := MntInfCnt(cCodBem, dDatOdo, cHorOdo, nTpCont, nOdo1)
				Else
					NGTRETCON(cCodBem,dDatOdo,nOdo1,cHorOdo,nTpCont,{},.T.,,,,,aTrbEst) //--Atualiza ST9, de acordo com o Odometro do Pai.
				EndIf
				If !aRet3[1] .And. lFi3CtPro //--Não foi montada a estrutura no momento da saida do veículo e Bem Possui contador Próprio
					If lFunCont
						lRet := MntInfCnt(cBemFi3, dDatOdo, cHorOdo, nTpCont, nOdo4)
					Else
						NGTRETCON(cBemFi3,dDatOdo,nOdo4,cHorOdo,nTpCont,{},.T.,,,,,aTrbEst) //--Atualiza ST9, de acordo com o Odometro Próprio.
					EndIf
				EndIf
			EndIf
		Elseif nAcao == 2//--Desmontagem da Estrutura

			If Empty(cTMSREst)
				Help("",1,"TMSXFUNA41") //--Informar a ocorrencia para desmontagem da Estrutura. MV_TMSREST"
				lRet := .F.
			Else
				If lEstorno
					//--Exclui apontamento do Bem Atual
					MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
					If lFi1CtPro
						MNT470EXCO(cBemFi1,dDatOdo,cHorOdo,1,aTrbEst)
					EndIf
					If	lFi2CtPro
						MNT470EXCO(cBemFi2,dDatOdo,cHorOdo,1,aTrbEst)
					EndIf
					If	lFi3CtPro
						MNT470EXCO(cBemFi3,dDatOdo,cHorOdo,1,aTrbEst)
					EndIf
					//Se for Estorno utiliza data atual para nao confrontar com o horário da movimentação da estrutura
					dDatOdo := dDataBase
					cHorOdo := Left(Time(),5)
				Else
					If Empty(cBemFi1)
						If lFunCont
							lRet := MntInfCnt(cCodBem, dDatOdo, cHorOdo, nTpCont, nOdo1)
						Else
							NGTRETCON(cCodBem,dDatOdo,nOdo1,cHorOdo,nTpCont,{},.T.,,,,,aTrbEst)
						EndIf
					EndIf
				EndIf

				If lRet .And. !Empty(cBemFi1)
					//--Acrescenta um minuto na Hora a ser gravada na estrutura do Bem.
					//--O SIGAMNT não permite retirada de um bem da estrutura caso o hora de saída não seja maior que a hora de entrada
					SomaDiaHor(@dDatOdo,@cHorOdo,HoraToInt("00:01"))//Hora:Minutos
					//-- Verifica se o bem é controlado pelo Contador próprio
					If lFi1CtPro
						aRet1 := NGESESTR(cCodBem,cBemFi1,nOdo1,dDatOdo,cHorOdo,nTpCont,"S",cTMSREst,,aTrbEst)
						If lFunCont
							lRet := MntInfCnt(cCodBem, dDatOdo, cHorOdo, nTpCont, nOdo1)
						Else
							NGTRETCON(cCodBem,dDatOdo,nOdo2,cHorOdo,nTpCont,{},.T.,,,,,aTrbEst)
						EndIf
					ElseIf Posicione("ST9",1,xFilial("ST9")+cBemFi1,"T9_TEMCONT") == "P"
						aRet1 := NGESESTR(cCodBem,cBemFi1,nOdo1,dDatOdo,cHorOdo,nTpCont,"S",cTMSREst,,aTrbEst)
					EndIf
					If !aRet1[1]
						Help("",1,"TMSXFUNA40",,aRet1[2],3,1) //"Nao foi atualizado o Odometro do Bem"
					ElseIf lEstorno
						MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
						If lFi1CtPro
							MNT470EXCO(cBemFi1,dDatOdo,cHorOdo,1,aTrbEst)
						EndIf
					EndIf
				EndIf

				If lRet .And. !Empty(cBemFi2)

					If !lEstorno .And. aRet1[1]	//-- Se não for estorno e montou a estrutura, exclui o apontamento feito pela estrutura
						MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
					EndIf

					If lFi2CtPro
						aRet2 := NGESESTR(cCodBem,cBemFi2,nOdo3,dDatOdo,cHorOdo,nTpCont,"S",cTMSREst,,aTrbEst)
						If lFunCont
							lRet := MntInfCnt(cCodBem, dDatOdo, cHorOdo, nTpCont, nOdo1)
						Else
							NGTRETCON(cCodBem,dDatOdo,nOdo1,cHorOdo,nTpCont,{},.T.,,,,,aTrbEst)//-- Verifica se o bem é controlado pelo Bem Pai da Estrutura
						EndIf
					ElseIf Posicione("ST9",1,xFilial("ST9")+cBemFi2,"T9_TEMCONT") == "P"
						aRet2 := NGESESTR(cCodBem,cBemFi2,nOdo1,dDatOdo,cHorOdo,nTpCont,"S",cTMSREst,,aTrbEst)
					EndIf

					If !aRet2[1]
						Help("",1,"TMSXFUNA40",,aRet2[2],3,1) //"Nao foi atualizado o Odometro do Bem"
						lRet := .F.
					ElseIf lEstorno
						MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
						If lEstorno .And. lFi2CtPro
							MNT470EXCO(cBemFi2,dDatOdo,cHorOdo,1,aTrbEst)
						EndIf
					EndIf

				EndIf
				If lRet .And. !Empty(cBemFi3)

					If !lEstorno .And. aRet1[1]	//-- Se não for estorno e montou a estrutura, exclui o apontamento feito pela estrutura
						MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
					EndIf

					If lFi3CtPro
						aRet3 := NGESESTR(cCodBem,cBemFi3,nOdo1,dDatOdo,cHorOdo,nTpCont,"S",cTMSREst,,aTrbEst)
						If lFunCont
							lRet := MntInfCnt(cBemFi3, dDatOdo, cHorOdo, nTpCont, nOdo4)
						Else
							NGTRETCON(cBemFi3,dDatOdo,nOdo4,cHorOdo,nTpCont,{},.T.,,,,,aTrbEst)//-- Verifica se o bem é controlado pelo Bem Pai da Estrutura
						EndIf
					Else
						aRet3 := NGESESTR(cCodBem,cBemFi3,nOdo1,dDatOdo,cHorOdo,nTpCont,"S",cTMSREst,,aTrbEst)
					EndIf

					If !aRet3[1]
						Help("",1,"TMSXFUNA40",,aRet3[2],3,1) //"Nao foi atualizado o Odometro do Bem"
						lRet := .F.
					ElseIf lEstorno
						MNT470EXCO(cCodBem,dDatOdo,cHorOdo,1,aTrbEst)
						If lEstorno .And. lFi3CtPro
							MNT470EXCO(cBemFi3,dDatOdo,cHorOdo,1,aTrbEst)
						EndIf
					EndIf
				EndIf
			EndIf

		ElseIf nAcao == 3 .And. lGeraOs //-- Gera ordem de servico
			//-- Verifica se existe manutenção preventiva para o Bem
			NGGEROSAUT(cCodBem,nOdo1,0,aTrbEst)
			If !Empty(cBemFi1)
				If Empty(nOdo2)
					nOdo2 := Posicione("ST9",1,xFilial("ST9")+cBemFi1,"T9_POSCONT")
				EndIf
				NGGEROSAUT(cCodBem,nOdo2,cBemFi1,aTrbEst)
			EndIf
			If !Empty(cBemFi2)
				If Empty(nOdo3)
					nOdo3 := Posicione("ST9",1,xFilial("ST9")+cBemFi2,"T9_POSCONT")
				EndIf
				NGGEROSAUT(cCodBem,nOdo3,cBemFi2,aTrbEst)
			EndIf
			If !Empty(cBemFi3)
				If Empty(nOdo4)
					nOdo4 := Posicione("ST9",1,xFilial("ST9")+cBemFi3,"T9_POSCONT")
				EndIf
				NGGEROSAUT(cCodBem,nOdo4,cBemFi3,aTrbEst)
			EndIf
		EndIf
	Else
		Help(' ',1,STR0078 ,,"Para utilizar a integração junto ao SIGAMNT será necessário atualizar a rotina MNTA470",2,0,,,,,,)
		lRet := .F.
	EndIf
EndIf

RestArea( aArea )
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSUltDTO ³ Autor ³ Eduardo de Souza      ³ Data ³ 14/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna dados da ultima entrada do motorista               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSUltDTO()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Motorista                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSUltDTO(cCodMot)

Local cAliasQry  := GetNextAlias()
Local cAliasQry2 := GetNextAlias()
Local cAliasQry3 := GetNextAlias()
Local aRet       := {}

cQuery := " SELECT MAX(DTO_DATENT) DATENT "
cQuery += "   FROM " + RetSqlName("DTO")
cQuery += "   WHERE DTO_CODMOT = '" + cCodMot + "' "
cQuery += "     AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof())
	cQuery := " SELECT MAX(DTO_HORENT) HORENT "
	cQuery += "   FROM " + RetSqlName("DTO")
	cQuery += "   WHERE DTO_CODMOT = '" + cCodMot + "' "
	cQuery += "	    AND DTO_DATENT = '" + (cAliasQry)->DATENT + "' "
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry2, .F., .T.)
	If (cAliasQry2)->(!Eof())
		cQuery := " SELECT MAX(R_E_C_N_O_) DTOREC "
		cQuery += "   FROM " + RetSqlName("DTO")
		cQuery += "   WHERE DTO_CODMOT = '" + cCodMot + "' "
		cQuery += "	    AND DTO_DATENT = '" + (cAliasQry )->DATENT + "' "
		cQuery += "	    AND DTO_HORENT = '" + (cAliasQry2)->HORENT + "' "
		cQuery += "     AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry3, .F., .T.)
		If (cAliasQry3)->(!Eof())
			DTO->(DbGoTo((cAliasQry3)->DTOREC))
			AAdd( aRet, { DTO->DTO_FILIAL } )
		EndIf
		(cAliasQry3)->(DbCloseArea())
	EndIf
	(cAliasQry2)->(DbCloseArea())
EndIf
(cAliasQry)->(DbCloseArea())

Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSOperPdg³ Autor ³ Vitor Raspa           ³ Data ³ 26.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acessa o WebService da Operadora para retornar o valor do  ³±±
±±³          ³ Pedagio                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSOperPdg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da Operadora                                ³±±
±±³          ³ ExpC2 - Codigo da Rota                                     ³±±
±±³          ³ ExpN1 - Qtde. de Eixos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSOperPdg( cCodOpe, cRotaVge, nQtdEix, nQtdEixV, nQtdUti, nQtEixVeic, lFailPdg, cFroVei, aPtoDca )
Local aArea    := GetArea()
Local aAreaSIX := SIX->(GetArea())
Local cXML     := ''
Local nValPdg  := 0
Local nCodEixo := 0 // Código da quantidade de eixos no sistema Pamcard
Local cError   := ''
Local cWarning := ''
Local aMsgErr  := {}
Local lTMSXML  := GetMV( 'MV_TMSXML',, .F. )
Local cRoteir  := ''
Local cPercur  := ''
Local aRetCNPJ := {} // Array com dados de contratente e filial de origem
Local aFields  := {}
Local lPagBem  := FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

Local oObj, oXML

Default aPtoDca   := {}
Default nQtdUti   := 0
Default nQtdEix   := 0
Default nQtdEixV  := 0
Default nQtEixVeic:= 0    //Qtde Total Eixos (Cavalo + Reboques)

lFailPdg := .F.

SetVarNameLen( 255 )

If cCodOpe == '01' //-- REPOM TECNOLOGIA
	DEG->( DbSetOrder(1) )
	If DEG->( MsSeek(xFilial('DEG')+cCodOpe) )
		//-- Posiciona no cadastro de Rotas X Operadoras
		SIX->(DbSetOrder(1))
		If SIX->(MsSeek('DEK' + '3'))
			DEK->( DbSetOrder(3) )
			If DEK->( MsSeek(xFilial('DEK')+cRotaVge+cFroVei+cCodOpe) )
				cRoteir := AllTrim(DEK->DEK_ROTEIR)
				cPercur := AllTrim(DEK->DEK_CODPER)
			ElseIf DEK->( MsSeek(xFilial('DEK')+cRotaVge+'0'+cCodOpe) )
				cRoteir := AllTrim(DEK->DEK_ROTEIR)
				cPercur := AllTrim(DEK->DEK_CODPER)
			ElseIf DEK->( MsSeek(xFilial('DEK')+DTQ->DTQ_ROTA+' '+cCodOpe) )
				cRoteir := AllTrim(DEK->DEK_ROTEIR)
				cPercur := AllTrim(DEK->DEK_CODPER)
			EndIf
		Else
			DEK->(DbSetOrder(2))
			If DEK->( MsSeek(xFilial('DEK') + cRotaVge + cCodOpe) )
				cRoteir := AllTrim(DEK->DEK_ROTEIR)
				cPercur := AllTrim(DEK->DEK_CODPER)
			EndIf
		EndIf
	
		If !lRestRepom
			//-- Gera XML para envio
			cXML += '<roteiro>'
			If !Empty(cRoteir) .And. !Empty(cPercur)
				cXML += '	<roteiro_codigo>' + cRoteir + '</roteiro_codigo>'
				cXML += '	<percurso_codigo>' + cPercur + '</percurso_codigo>'
			Else
				cXML += '	<roteiro_codigo/>'
				cXML += '	<percurso_codigo/>'
			EndIf
			cXML += '	<roteiro_cliente_codigo/>'

			cXML += '	<numero_eixos>' + AllTrim( Str(nQtEixVeic,2 ) ) + '</numero_eixos>'                  //Qtde Total Eixos (Cavalo + Carreta)
			cXML += '	<eixos_suspensos_ida>' +  AllTrim( Str((nQtEixVeic - nQtdEix),2) )  + '</eixos_suspensos_ida>'       //Qtde Eixos Ida
			cXML += '	<eixos_suspensos_volta>' + AllTrim( Str((nQtEixVeic - nQtdEixV),2) )  + '</eixos_suspensos_volta>'    //Qtde Eixos Volta
			cXML	+= '</roteiro>'

			//-- Remove Acentos e Caracteres especiais
			cXML := TMSNoAcento( cXML )

			//-- Gera XML em Disco
			If lTMSXML
				TMSLogXML( cXML, 'RoteiroValorTotalVPRs.XML' )
			EndIf

			oObj := WSIntegracao():New()
			oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
			oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
			oObj:cstrXmlIn             := cXML
			oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora

			If oObj:RoteiroValorTotalVPRs()
				If oObj:lRoteiroValorTotalVPRsResult
					//-- Remove os acentos do XML de Retorno
					oObj:cStrXMLOut := TMSNoAcento( oObj:cStrXMLOut )
					//-- Gera XML em Disco
					If lTMSXML
						TMSLogXML( oObj:cStrXMLOut, 'RoteiroValorTotalVPRsResult.XML' )
					EndIf
					//-- Coverte em Objeto o XML de retorno enviado pela Operadora
					oXML := XMLParser( oObj:cStrXMLOut, '_', @cError, @cWarning )

					nValPdg := Val(oXML:_VALOR_VPR:_VALOR_TOTAL_VPR:TEXT)
				Else
					aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
					lFailPdg := .T.
				EndIf
			Else
				aMsgErr := TMSErrOper(cCodOpe,, '2')
				lFailPdg := .T.
			EndIf	
		Else
			//---- lRestRepom - Repom Versao 2.2
			nValPdg:= TMVlPdgRep(cRoteir, cPercur, nQtEixVeic, @lFailPdg, @aMsgErr)
		EndIf

		If lFailPdg
			TmsMsgErr( aMsgErr )
		EndIf
	EndIf
	
// Integração Sistema PamCard
ElseIf cCodOpe == '02' //-- PAMCARY

	nCodEixo := PamCatVeic(nQtdEix)
	aRetCNPJ := PamCNPJEmp(cCodOpe) //Função para obter CNPJ da contrante e filial de origem

	//Montagem Array com Dados - PamCard
	AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
	AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
	AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
	AAdd (aFields,{'viagem.veiculo.categoria', cValToChar(nCodEixo) } )

	//-- Verifica se o cliente trabalha com rota ou com pontos de descarga para calculo de pedagio e envio do contrato
	If SuperGetMv("MV_PAMROTA",.F.,.T.)
		AAdd (aFields,{'viagem.rota.nome', AllTrim(cRotaVge) } )
		AAdd (aFields,{'viagem.pedagio.obter.praca', 'N' } )
		AAdd (aFields,{'viagem.pedagio.obter.rota' , 'N' } )
	 	nValPdg := PamRouter(aFields)
	ElseIf Len(aPtoDca) > 0
		//-- Retorna pontos de descarga da viagem
		PamPtoDca(@aFields,,, aPtoDca )
		AAdd (aFields,{'viagem.pedagio.obter.praca', 'N' } )
		AAdd (aFields,{'viagem.pedagio.obter.rota' , 'N' } )
		nValPdg := PamRouter(aFields)
	EndIf
ElseIf cCodOpe == '03' .And. lPagBem //--PAGBEM 
	DEK->(DbSetOrder(2)) 
	If DEK->( MsSeek(xFilial('DEK') + cRotaVge + cCodOpe) )
		cRoteir := AllTrim(DEK->DEK_ROTEIR)
	EndIf
	nValPdg := PagBemPdg(cRoteir,nQtdEix) 
EndIf

SetVarNameLen( 10 )
RestArea( aArea )
RestArea( aAreaSIX )
Return( nValPdg )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsBrwbLin ³ Autor ³ Eduardo de Souza     ³ Data ³ 11/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da bLine                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsBrwbLin(ExpN1,ExpA1,ExpA2,ExpA3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao da linha no listbox                        ³±±
±±³          ³ Expa1 - Lista                                              ³±±
±±³          ³ Expa2 - Lista Ponto de Entrada                             ³±±
±±³          ³ Expa3 - Campos Adicionais no bline                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsBrwbLin(nAt,aList,aUsHList,aListCom)

Local abLine  := {}
Local nCnt    := 0
Local nPosIni := 0
Local oOk     := LoadBitMap(GetResources(),"LBOK")
Local oNo     := LoadBitMap(GetResources(),"LBNO")

//-- Utilizado na troca de rotas.
If nAt > Len(aList)
	Return( abLine )
EndIf

AAdd( abLine, If(aList[nAt,1],oOk,oNo) )
For nCnt := 2 To Len(aList[nAt])
	AAdd( abLine, aList[nAt,nCnt])
Next nCnt

//-- Inclui colunas do usuario
If lTMBRWCOL .And. !Empty(aUsHList)
	nPosIni  := (Len(aList[nAt]) - Len(aUsHList)) + 1
	For nCnt := nPosIni To Len(aList[nAt])
		AAdd( abLine, aList[nAt,nCnt] )
	Next nCnt
EndIf

Return( abLine )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSIntMnt ³ Autor ³Robson Alves           ³ Data ³24.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua integracao com manutencao de ativos. No apontamento ³±±
±±³          ³da atividade de inspecao e no lançamento da despesa.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSIntMnt(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpA1,ExpA2, ³±±
±±			 ³			 ExpA3,ExpL1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo de Integração (1=Inspecao;2=Despesas)         ³±±
±±³          ³ ExpC2 = Servico da Manutencao                              ³±±
±±³          ³ ExpC3 = Filial de Origem da Viagem                         ³±±
±±³          ³ ExpC4 = Numero da Viagem   								  ³±±
±±³          ³ ExpC5 = Codigo do Veiculo   							      ³±±
±±³          ³ ExpC6 = Codigo da Despesa 								  ³±±
±±³          ³ ExpA1 = Array com itens a serem exibidos no checkList      ³±±
±±³          ³ ExpA2 = Array com itens que gerarao Ordens de Servico	  ³±±
±±³          ³ ExpA3 = Array com Acols da Prestacao de Contas	          ³±±
±±³          ³ ExpL1 = .T. Adiantamneto - .F. Despesa					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSIntMnt( cTipo, cSerMnt, cFilOri, cViagem, cCodVei, cCodDesp, aFolder, aFolderBkp, aItem, lAdto)

Local aArea      := GetArea()
Local lRet       := .T.
Local aBensVgm   := {}

Private aItensChk:= {}

Default aFolder  := {}
Default cFilOri  := ''
Default cViagem  := ''
Default cCodvei  := ''
Default cCodDesp := ''
Default cSerMnt  := ''
Default aItem    := {}
Default lAdto    := .F.

//-- Verifica se os parametros foram preenchidos.
If Empty( cSerMnt )
	Aviso(STR0078, STR0185 + If( cTipo == '1', STR0186, STR0187 ) , {STR0090})//"ATENÇÃO"###"Informe o serviço de:"###"Inspeção! - MV_SERVISP"###"Despesa - MV_SERDESP"###"OK"
	Return( .F. )
EndIf

//-- Verifica se o servico foi cadastrado.
ST4->( dbSetOrder( 1 ) )
If !ST4->( MsSeek(xFilial("ST4") + cSerMnt ) )
	Aviso( STR0078, STR0189 + cSerMnt + STR0190, {STR0090} )    //"ATENÇÃO"###"O Serviço: "###"não foi encontrado!"
	Return( .F. )
EndIf

//-- Integracao com MNT no Apontamento de Operacoes.
If cTipo == '1'

	//-- Se o campo DTW_HORINI for digitado novamente, exibe os dados ja existentes.
	If !Empty( aFolder)
		CursorWait()
		MsgRun( STR0191,, { || lRet := TMSAShwLst( , .F., cTipo, M->DTW_FILORI, M->DTW_VIAGEM, @aFolder  ) } ) //"Aguarde, processando Manutenção dos bens da Viagem..."
		CursorArrow()
	Else
		CursorWait()
		MsgRun( STR0192,, { || aBensVgm := TMSMntBens( cFilOri, cViagem ) } ) //""Aguarde, processando os Bens utilizados na Viagem..."
		CursorArrow()
		lRet     := !Empty ( aBensVgm )
		If lRet
			CursorWait()
			MsgRun( STR0191,, { || lRet := TMSAShwLst( aBensVgm, , cTipo, cFilOri, cViagem, , ,cSerMnt, @aFolder) } )//"Aguarde, processando Manutenção dos bens da Viagem..."
			CursorArrow()
		EndIf
	EndIf

//-- Integracao com MNT no Lancamento das Despesas.
ElseIf cTipo == '2'
	If Empty(cCodVei)
		CursorWait()
		MsgRun( STR0192,, { || aBensVgm := TMSMntBens( cFilOri, cViagem, cTipo, cCodDesp ) } )//"Aguarde, processando os Bens utilizados na Viagem..."
		CursorArrow()
		lRet     := !Empty ( aBensVgm )
	EndIf

	If lRet
		CursorWait()
		MsgRun( STR0191,, { || lRet := TMSAShwLst( aBensVgm, , cTipo, cFilOri, cViagem, cCodDesp, cCodVei, cSerMnt, @aFolder, @aFolderBkp, aItem, lAdto ) } )//"//"Aguarde, processando Manutenção dos bens da Viagem..."
		CursorArrow()
	EndIf
EndIf

RestArea( aArea )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAShwLst³ Autor ³Robson Alves       	³ Data ³24.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe tela com as tarefas do Check List.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAShwLst()                       	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSAShwLst( aBensVgm, lProcessa, cTipo, cFilOri, cViagem, cCodDesp, cCodVei, cSerMnt, aFolder, aFolderBkp, aItem, lAdto)

Local aArea       := GetArea()
Local cDesFolder  := ""
Local aListAux    := {}
Local aPages      := {}
Local aTitles     := {}
Local nA          := 0
Local nB          := 0
Local nLoop       := 0
Local oNoMarked   := LoadBitmap(GetResources(),'LBNO')
Local oMarked	   := LoadBitmap (GetResources(),'LBOK')
Local nOpca       := 0
Local cQuery      := ""
Local cAlias      := ""
Local lRet        := .T.
Local cTitulo     := If( cTipo == "1", STR0193 + cFilOri + " - " + cViagem,; //"Inspeção dos Bens utilizados na Viagem: "
 													 If (Empty(cCodVei),STR0194+ cFilOri + " - " + cViagem,STR0211 + cCodVei  ) ) //"Despesas de Manutenções ocorridas na Viagem: "
Local nPosBkp	   := 0
Local cCodFam	   := ''
Local nVlrTotMnt  := 0
Local lMrkEtapa   := .F.

Default cCodDesp  := ''

Default lProcessa 	:= .T.
Default aFolder		:= {}
Default aFolderBkp	:= {}
Default aBensVgm	:= {}
Default aItem		:= {}
Default cTipo		:= ''
Default cSerMnt	:= ''
Default cCodVei	:= ''
Default cViagem	:= ''
Default cFilOri	:= ''

aFolder := {}

If lProcessa
	If (nPosBkp := aScan(aFolderBkp,{|x| x[1] +x[2] + x[3]+ x[4]   == cFilOri+cViagem+cCodDesp+cCodVei}) )  == 0
		If !Empty(cCodvei)
			If cTipo ==  "2"
				DT7->( dbSetOrder( 1 ) )
				If DT7->( MsSeek( xFilial("DT7") + cCodDesp ) )
					If !Empty( DT7->DT7_CODFAM )
						cCodFam := DT7->DT7_CODFAM
					Else
						Aviso( STR0078, STR0204, {STR0090} )//"Atenção"###"Código da Família não informada na Despesa."###"OK"
						lRet := .F.
					EndIf
				EndIf
			EndIf
			aListAux   := {}
			cAlias     := GetNextAlias()
			cDesFolder := (STR0195  + STR0196  + " : " + cCodVei)

			//-- Obtem as tarefas e etapas vinculadas a familia e servico dos veiculos.
			cQuery := "SELECT TTE.TTE_ETAPA, TPA.TPA_DESCRI 		  " 		+ CRLF
			cQuery += "  FROM " + RetSqlName("TTE") 			+ " TTE " 		+ CRLF
			cQuery += "    INNER JOIN " + RetSqlName("TPA") + " TPA " 		+ CRLF
			cQuery += "    ON  TTE.TTE_ETAPA  = TPA_ETAPA "		   			+ CRLF

			cQuery += "  WHERE TTE.TTE_FILIAL = '" + xFilial("TTE") 	+ "'"	+ CRLF
			cQuery += "    AND TTE.TTE_CODFAM = '" + cCodFam 		 	+ "'"	+ CRLF
			cQuery += "		AND TTE.TTE_SERVIC = '" + cSerMnt 		 	+ "'"	+ CRLF
			cQuery += "		AND TPA.TPA_FILIAL = '" + xFilial("TPA") 	+ "'"	+ CRLF
			cQuery += "		AND TTE.D_E_L_E_T_ = ' '" 			  	 			 	+ CRLF
			cQuery += "		AND TPA.D_E_L_E_T_ = ' '"

			cQuery += "  GROUP BY TTE_ETAPA, TPA_DESCRI, TTE_CODFAM "
			cQuery := ChangeQuery(cQuery)

			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

			If (cAlias)->(Eof())
				Aviso( STR0078, STR0198 + cCodFam + STR0212 + AllTrim(cCodDesp) + ". - " + STR0052 + cSerMnt + STR0199 + cCodvei, {STR0090}) //"ATENÇÃO"###"Não existe Manutenção Padrão ou etapas cadastradas para Familia : "###",  Servico : "###" e Bem:" ###"OK"
				Return .F.
			EndIf

			While !(cAlias)->(Eof())
				Aadd( aListAux, { .F. ,;
				(cAlias)->TTE_ETAPA,;
				AllTrim( (cAlias)->TPA_DESCRI ),;
				cCodVei,;
				0 } )

				(cAlias)->(dbSkip())
			EndDo

			(cAlias)->( dbCloseArea() )


			//-- Adiciona ao folder.
			Aadd( aFolder, {	cDesFolder,;
			aListAux	,;
			Nil		})

		Else

			For nA := 1 To Len( aBensVgm )
				For nB := 1 To Len( aBensVgm[nA] )
					aListAux   := {}
					cAlias     := GetNextAlias()
					cDesFolder := STR0195 + If( aBensVgm[nA, nB, 3], STR0196, STR0197 ) + " : " + aBensVgm[nA, nB, 1]

					//-- Obtem as tarefas e etapas vinculadas a familia e servico dos veiculos.
					cQuery := "SELECT TTE.TTE_ETAPA, TPA.TPA_DESCRI 		 " 		   + CRLF
					cQuery += "  FROM " + RetSqlName("TTE") + " TTE 		 " 		   + CRLF
					cQuery += "    INNER JOIN " + RetSqlName("TPA")  + " TPA " 		   + CRLF
					cQuery += "    ON  TTE.TTE_ETAPA  = TPA_ETAPA "		   		  	   + CRLF

					cQuery += "  WHERE TTE.TTE_FILIAL = '" + xFilial("TTE") 	 + "'" + CRLF
					cQuery += "    	AND TTE.TTE_CODFAM = '" + aBensVgm[nA, nB, 2]+ "'" + CRLF
					cQuery += "		AND TTE.TTE_SERVIC = '" + cSerMnt 		 	 + "'" + CRLF
					cQuery += "		AND TPA.TPA_FILIAL = '" + xFilial("TPA") 	 + "'" + CRLF
					cQuery += "		AND TTE.D_E_L_E_T_ = ' '" 			 	 	 	   + CRLF
					cQuery += "		AND TPA.D_E_L_E_T_ = ' '"
					cQuery += " GROUP BY TTE_ETAPA, TPA_DESCRI, TTE_CODFAM "
					cQuery := ChangeQuery(cQuery)

					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)


					If (cAlias)->(Eof())
						Aviso( STR0078, STR0198 + aBensVgm[nA, nB, 2] + STR0212 + cCodDesp + ". - " + STR0052 + cSerMnt + STR0199 + aBensVgm[nA, nB, 1], {STR0090}) //"ATENÇÃO"###"Não existe Manutenção Padrão ou etapas cadastradas para Familia : "###",  Servico : "###" e Bem:" ###"OK"
						lRet := .F.
						Exit
					EndIf

					While !(cAlias)->(Eof())
						Aadd( aListAux, { .F. ,;
						(cAlias)->TTE_ETAPA,;
						AllTrim( (cAlias)->TPA_DESCRI ),;
						aBensVgm[nA, nB, 1],;
						0 } )

						(cAlias)->(dbSkip())
					EndDo

					(cAlias)->( dbCloseArea() )

					//-- Adiciona ao folder.
					Aadd( aFolder, {	cDesFolder,;
					aListAux	,;
					Nil		})

				Next nB

				If !lRet
					Exit
				EndIf

			Next nA
		EndIf
	Else
		aFolder:= aClone(aFolderBkp[nPosBkp,5])
	EndIf
EndIf


If !Empty( aFolder )
	DEFINE MSDIALOG oDlgIsp TITLE cTitulo FROM 194,52 TO 633,760 PIXEL
	Aeval( aFolder, { | aFolderLine | 	Aadd( aTitles, aFolderLine[1] ), Aadd( aPages,  "AHEADER" ) } )
	//-- Cria as Folders do Sistema.
	oFolder := TFolder():New( 30,08, aTitles,aPages,oDlgIsp,,,,.T.,.F., 343, 187, )

	//-- Carrega os objetos.
	For nLoop := Len( aFolder ) TO 1 STEP - 1
		aItensChk := aClone( aFolder[nLoop][2] )

		If cTipo == "1"
			@ 05, 05 LISTBOX oLbx VAR cLbx1 FIELDS;
			HEADER "",;
			STR0201,;//"Etapa"
			STR0014;//"Descrição"
			SIZE 333, 167 OF oFolder:aDialogs[nLoop] ON DBLCLICK ( TMSAMntMrk( cTipo, oFolder:nOption, aFolder ) ) PIXEL
		Else
			@ 05, 05 LISTBOX oLbx VAR cLbx1 FIELDS;
			HEADER "",;
			STR0201,;//"Etapa"
			STR0014,;//"Descrição"
			STR0202,;//Valor Despesa"
			SIZE 333, 167 OF oFolder:aDialogs[nLoop] ON DBLCLICK ( TMSAMntMrk( cTipo, oFolder:nOption, aFolder, aItem, @nVlrTotMnt,@lMrkEtapa ) ) PIXEL
		EndIf

		oLbx:SetArray( aItensChk )

		If cTipo == "1"
			oLbx:bLine	:= { || { Iif(aItensChk[oLbx:nAT,1] , oMarked, oNoMarked ),;
			aItensChk[oLbx:nAT,2],;
			aItensChk[oLbx:nAT,3]}}
		Else
			oLbx:bLine	:= { || { Iif(aItensChk[oLbx:nAT,1] , oMarked, oNoMarked ),;
			aItensChk[oLbx:nAT,2],;
			aItensChk[oLbx:nAT,3],;
			Transform(  aItensChk[oLbx:nAT,5], "@E 999,999,999,999.99" ) } }
		EndIf

		aFolder[nLoop][3]:= oLbx
		aFolder[nLoop][3]:Refresh(.T.)
		aFolder[nLoop][2]:= aClone( aItensChk )

		nFolder := nLoop
	Next nLoop
	//-- Habilita o troca de Folder.
	oFolder:bSetOption:={|nAtu| TMSAMntChg( nAtu, oFolder:nOption, aFolder ) }
	ACTIVATE MSDIALOG oDlgIsp CENTERED ON INIT EnchoiceBar( oDlgIsp, {|| nOpca:=1, aFolder[oFolder:nOption][2] := aClone( aItensChk ),;
																	oDlgIsp:End() }, {|| lRet := .F., oDlgIsp:End() } )
		If cTipo == '2'
			If nOpca == 1
				If (nPosBkp := aScan(aFolderBkp,{|x| x[1] +x[2] + x[3]+ x[4] == cFilOri+cViagem+cCodDesp+cCodVei}) )  == 0
					Aadd( aFolderBkp, {AllTrim(cFilOri),AllTrim(cViagem),AllTrim(cCodDesp),AllTrim(cCodVei),aClone(aFolder)} )
				Else
					aFolderBkp[nPosBkp] := {AllTrim(cFilOri),AllTrim(cViagem),AllTrim(cCodDesp),AllTrim(cCodVei),aClone(aFolder)}
				EndIf
				If lAdto
				     If lMrkEtapa
				     	GdFieldPut('EU_VALOR', nVlrTotMnt)
				     EndIf
				EndIf
			EndIf
		EndIf

EndIf

RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAMntChg³ Autor ³Robson Alves           ³ Data ³24.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Controla troca de Folder.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAMntChg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSAMntChg( nTargetFolder, nSourceFolder,aFolder )

Local lRet := .T.
Default aFolder := {}

aFolder[nSourceFolder][2] := aClone( aItensChk )
aItensChk := aClone( aFolder[nTargetFolder][2] )
oLbx      := aFolder[nTargetFolder][3]

aFolder[nTargetFolder][3]:SetFocus()
nFolder := nTargetFolder
oFolder:nOption := nTargetFolder

oDlgIsp:Refresh()
oFolder:Refresh()
oLbx:Refresh()

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSMntBens³ Autor ³Robson Alves           ³ Data ³24.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna os bens utilizados na Viagem.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSMntBens()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSMntBens( cFilOri, cViagem, cTipo, cCodDesp)

Local cQuery      := ""
Local cAlias      := GetNextAlias()
Local aBensAux    := {}
Local aBensVgm    := {}
Local lRet        := .T.
Local cCodFam     := ""
Local lTercRbq	  := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local cCodBem	  := ""

Default cTipo     := "1"
Default cFilOri   := ""
Default cViagem   := ""
Default cCodDesp  := ''

If lTercRbq
	cQuery := "SELECT DTR_CODVEI, DTR_CODRB1, DTR_CODRB2, DTR_CODRB3 "
Else
	cQuery := "SELECT DTR_CODVEI, DTR_CODRB1, DTR_CODRB2 "
EndIf
cQuery += "FROM " + RetSqlName("DTR")
cQuery += " WHERE DTR_FILIAL = '" + xFilial("DTR") + "' AND"
cQuery += " DTR_FILORI = '" + cFilOri + "' AND"
cQuery += " DTR_VIAGEM = '" + cViagem + "' AND"
cQuery += " D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

DA3->( dbSetOrder( 1 ) )
DUT->( dbSetOrder( 1 ) )
ST9->( dbSetOrder( 15 ) )
If cTipo == "2"
	DT7->( dbSetOrder( 1 ) )
	If DT7->( MsSeek( xFilial("DT7") + cCodDesp ) )
		If !Empty( DT7->DT7_CODFAM )
			cCodFam := DT7->DT7_CODFAM
		Else
			Aviso( STR0078, STR0204, {STR0090} )//"Atenção"###"Código da Família não informada na Despesa."###"OK"
			lRet := .F.
		EndIf
	EndIf
EndIf

While lRet .And. (cAlias)->( !Eof() )

	//-- Obtem o tipo do Veiculo.
	If DA3->( MsSeek( xFilial("DA3") + (cAlias)->DTR_CODVEI ) )

		//-- Verifica se o bem foi cadastrado.
		If !ST9->( MsSeek(xFilial("ST9") + (cAlias)->DTR_CODVEI ) )
			Aviso( STR0078, STR0205 + (cAlias)->DTR_CODVEI + STR0206 , {STR0090} )//"ATENÇÃO" ###"Código do bem : "###não foi cadastrado."###"OK"
			lRet := .F.
		Else
			cCodBem	:= ST9->T9_CODBEM
		EndIf

		If cTipo == "1"
			//-- Obtem o serviço de inspecao.
			If DUT->( MsSeek( xFilial("DUT") + DA3->DA3_TIPVEI ) )
				If !Empty( DUT->DUT_CODFAM )
					Aadd( aBensAux, { Padr(cCodBem,Len(STF->TF_CODBEM)), DUT->DUT_CODFAM, .T. } )
				Else
					Aviso( STR0078, STR0207 + STR0208 + DUT->DUT_TIPVEI  + " - " + Alltrim( DUT->DUT_DESCRI ), {STR0090} )//"ATENÇÃO"###""Código da Família não informado. "###"Tipo de Veículo: "###"OK"
					lRet := .F.
				EndIf
			EndIf
		Else
			Aadd( aBensAux, { cCodBem, cCodFam, .T. } )
		EndIf
	EndIf

		//-- Obtem o tipo do 1o Reboque.
	If !Empty( (cAlias)->DTR_CODRB1 )
		//-- Obtem o tipo do Veiculo.
		If DA3->( MsSeek( xFilial("DA3") + (cAlias)->DTR_CODRB1 ) )

			//-- Verifica se o bem foi cadastrado.	
			If !ST9->( MsSeek(xFilial("ST9") + (cAlias)->DTR_CODRB1 ) )
				Aviso( STR0078, STR0205 + (cAlias)->DTR_CODRB1 + STR0206 , {STR0090} )//"Atenção"###""Código do bem : "###" não foi cadastrado."###"Ok"
				lRet := .F.
			Else 
				cCodBem := ST9->T9_CODBEM
			EndIf

			If cTipo == "1"
				//-- Obtem o serviço de inspecao.
				If DUT->( MsSeek( xFilial("DUT") + DA3->DA3_TIPVEI ) )
					If !Empty( DUT->DUT_CODFAM )
						Aadd( aBensAux, { Padr(cCodBem,Len(STF->TF_CODBEM)), DUT->DUT_CODFAM, .F. } )
					Else
						Aviso( STR0078, STR0207 + STR0208 + DUT->DUT_TIPVEI  + " - " + Alltrim( DUT->DUT_DESCRI ), {STR0090} )//"ATENÇÃO"###""Código da Família não informado. "###"Tipo de Veículo: "###"OK"
						lRet := .F.
					EndIf
				EndIf
			Else
				Aadd( aBensAux, { cCodBem, cCodFam, .F. } )
			EndIf
		EndIf
	EndIf

	//-- Obtem o tipo do 2o Reboque.
	If !Empty( (cAlias)->DTR_CODRB2 )
		//-- Obtem o tipo do Veiculo.
		If DA3->( MsSeek( xFilial("DA3") + (cAlias)->DTR_CODRB2 ) )

			//-- Verifica se o bem foi cadastrado.
			If !ST9->( MsSeek(xFilial("ST9") + (cAlias)->DTR_CODRB2 ) )
				Aviso( STR0078, STR0205 + (cAlias)->DTR_CODRB1 + STR0206 , {STR0090} )//"Atenção"###""Código do bem : "###" não foi cadastrado."###"Ok"
				lRet := .F.
			Else 
				cCodBem	:= ST9->T9_CODBEM
			EndIf

			If cTipo == "1"
				//-- Obtem o serviço de inspecao.
				If DUT->( MsSeek( xFilial("DUT") + DA3->DA3_TIPVEI ) )
					If !Empty( DUT->DUT_CODFAM )
						Aadd( aBensAux, {Padr(cCodBem,Len(STF->TF_CODBEM)), DUT->DUT_CODFAM, .F. } )
					Else
						Aviso( STR0078, STR0207 + STR0208 + DUT->DUT_TIPVEI  + " - " + Alltrim( DUT->DUT_DESCRI ), {STR0090} )//"ATENÇÃO"###""Código da Família não informado. "###"Tipo de Veículo: "###"OK"
						lRet := .F.
					EndIf
				EndIf
			Else
				Aadd( aBensAux, { cCodBem , cCodFam, .F. } )
			EndIf
		EndIf
	EndIf

	//-- Obtem o tipo do 3o Reboque.
	If lTercRbq .And. !Empty( (cAlias)->DTR_CODRB3 )
		//-- Obtem o tipo do Veiculo.
		If DA3->( MsSeek( xFilial("DA3") + (cAlias)->DTR_CODRB3 ) )

			//-- Verifica se o bem foi cadastrado.
			If !ST9->( MsSeek(xFilial("ST9") + (cAlias)->DTR_CODRB3 ) )
				Aviso( STR0078, STR0205 + (cAlias)->DTR_CODRB3 + STR0206 , {STR0090} )//"Atenção"###""Código do bem : "###" não foi cadastrado."###"Ok"
				lRet := .F.
			Else 
				cCodBem	:= ST9->T9_CODBEM
			EndIf

			If cTipo == "1"
				//-- Obtem o serviço de inspecao.
				If DUT->( MsSeek( xFilial("DUT") + DA3->DA3_TIPVEI ) )
					If !Empty( DUT->DUT_CODFAM )
						Aadd( aBensAux, {Padr(cCodBem,Len(STF->TF_CODBEM)), DUT->DUT_CODFAM, .F. } )
					Else
						Aviso( STR0078, STR0207 + STR0208 + DUT->DUT_TIPVEI  + " - " + Alltrim( DUT->DUT_DESCRI ), {STR0090} )//"ATENÇÃO"###""Código da Família não informado. "###"Tipo de Veículo: "###"OK"
						lRet := .F.
					EndIf
				EndIf
			Else
				Aadd( aBensAux, { cCodBem , cCodFam, .F. } )
			EndIf
		EndIf
	EndIf
	(cAlias)->( dbSkip() )

EndDo
(cAlias)->( dbCloseArea() )

If lRet
	Aadd( aBensVgm, aBensAux )
EndIf

Return( aBensVgm )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAMntMrk³ Autor ³Robson Alves           ³ Data ³24.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca\Desmarca listbox.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAMntMrk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSAMntMrk( cTipo, nAtu, aFolder, aItem, nVlrTotMnt,lMrkEtapa )

Local oDlgGet	:= Nil
Local oPanel	:= Nil
Local oValor	:= Nil
Local cSay   	:= STR0202
Local nValor 	:= 0
Local nOpcA  	:= 0
Local nA, nB 	:= 0
Local nValorEst := 0
Local aIntMnt	:= {}

Default nAtu	 := 0
Default aFolder := {}

lMrkEtapa := .T.
nVlrTotMnt := 0
aItensChk[ oLbx:nAT, 1 ] := !aItensChk[ oLbx:nAT, 1 ]

If cTipo == "2"
	If aItensChk[ oLbx:nAT, 1 ]
		DEFINE MSDIALOG oDlgGet FROM 00,00 TO 100,290 PIXEL TITLE STR0203 //"Informe o valor da Despesa:"
			oPanel := tPanel():New(03,03,"",oDlgGet,,,,,CLR_WHITE,140, 30, .T.)

			@ 013, 005 SAY cSay SIZE 100,009 OF oPanel PIXEL COLOR CLR_BLUE
			@ 013, 085 MSGET oValor VAR nValor PICTURE PesqPict("DT6", "DT6_VALMER") VALID TmsMntVld( nValor, nAtu, aFolder, aItem, @nVlrTotMnt) SIZE 50, 010 OF oDlgGet PIXEL

		DEFINE SBUTTON FROM 37,115 TYPE 1 OF oDlgGet ENABLE ACTION (nOpcA := 1, oDlgGet:End())
		ACTIVATE MSDIALOG oDlgGet CENTERED
		If nOpcA == 1
			aItensChk[ oLbx:nAT, 5 ] := nValor
		Else
			aItensChk[ oLbx:nAT, 1 ] := !aItensChk[ oLbx:nAT, 1 ]
		EndIf
	Else
		nValorEst := aItensChk[ oLbx:nAT, 5 ]
		aItensChk[ oLbx:nAT, 5 ] := 0
		For nA := 1 To Len( aFolder )
			If nA == nAtu
				aIntMnt := aClone( aItensChk )
			Else
				aIntMnt := aClone( aFolder[nA, 2] )
			EndIf
			For nB := 1 To Len( aIntMnt )
				If aIntMnt[nB, 1]
					nVlrTotMnt += aIntMnt[nB, 5]
				Endif
			Next nB
		Next nA
		//SubTrai o valor da despesa caso a etapa seja dermarcado
		If !ADIANTAMENTO
			M->EU_VALOR -= nValorEst
		EndIf
	EndIf
EndIf

oLbx:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsMntVld ³ Autor ³Robson Alves           ³ Data ³24.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a digitacao do valor da despesa.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSMntVld()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TmsMntVld( nValAtu, nAtu, aFolder, aItem, nVlrTotMnt)

Local nA, nB, nC:= 0
Local nValorCols:= 0
Local lVlPrtCM  := GetNewPar("MV_PCTCXMA","2")=="1"  // Permite prestacao de contas a maior no adiantamento
Local nValDig 	 := 0
Local lRet 	 := .T.
Local aIntMnt	 := {}

Default aItem  := {}
Default aFolder := {}


nValDig 	:= 0

For nA := 1 To Len( aFolder )
	If nA == nAtu
		aIntMnt := aClone( aItensChk )
	Else
		aIntMnt := aClone( aFolder[nA, 2] )
	EndIf

	For nB := 1 To Len( aIntMnt )
		If aIntMnt[nB, 1]
			nValDig += aIntMnt[nB, 5]
		Endif
	Next nB
Next nA

If !ADIANTAMENTO
	M->EU_VALOR := nValAtu + nValDig
ElseIf !lVlPrtCM	// Validar se o Valor das manutenções não sucede o valor do Adiantamento
	If Len(aItem) > 1
		For nC := 1 to Len (aItem)
			If nC != n
				nValorCols += aItem[nC,8]
			EndIf
		Next
	EndIf
 	nVlrTotMnt := nValDig + nValAtu// nVlrTotMnt -- variavel private que irá preencher o EU_VALOR daquela despesa.
	RegToMemory('SEU',.F.)

	If M->EU_VALOR < (nValorCols + nVlrTotMnt)
		Aviso( STR0078, STR0209 +  "( " + AllTrim( Transform(  (nValorCols+nVlrTotMnt), "@E 999,999,999,999.99" ) ) ;//"ATENÇÃO"###"A soma dos valores informados"
		+ ")" + STR0210 + AllTrim( Transform(  M->EU_VALOR, "@E 999,999,999,999.99" ) ), {STR0090} ) //"não pode ser maior que o valor da Despesa: "###"OK"
		lRet := .F.
		nVlrTotMnt :=  nValDig // Se o valor for acima do adiantamento, preencher EU_VALOR, com valor já informado.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsMntSTQ ³ Autor ³Robson Alves           ³ Data ³24.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava os estapas da OS.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsMntSTQ()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsMntSTQ( cOrdem, cEtapa  )

Local aArea := GetArea()
Default cOrdem := ''
Default cEtapa := ''

Reclock("STQ", .T.)
STQ->TQ_FILIAL := xFilial("STQ")
STQ->TQ_ORDEM  := cOrdem
STQ->TQ_PLANO  := Posicione("STJ",1,xFilial("STJ")+cOrdem,"TJ_PLANO")
STQ->TQ_TAREFA := '0'
STQ->TQ_ETAPA  := cEtapa
MsUnLock()

RestArea( aArea )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsMntGrOs³ Autor ³Robson Alves          ³ Data ³24.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a Ordem de Serviço e sua estapas da OS.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSMntGrOs()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsMntGrOs( cTipo, cSerMnt, aFolder, aFolderBkp, aItem)

Local aIntMnt  	:= {}
Local nA, nB, nC	:= 0
Local lGerOs 	  	:= .F.
Local lMntTms    	:= ( SuperGetMV( "MV_NGMNTMS",,'N') == 'S' )//-- Ativa integracao TMS X MNT.
Local nPosFolder  := 0
LOcal cPrdCons := SuperGetMV("MV_PRODINS")

Default cTipo		:= ''
Default cSerMnt		:= ''
Default aFolder		:= ''
Default aFolderBkp	:= {}
Default aItem		:= {}

SaveInter()
If lMntTms
	If cTipo == '1' //Inspeção de Veículos
		For nA := 1 To Len( aFolder )
			aIntMnt := aClone( aFolder[nA, 2] )
			lGerOs  := .F.
			For nB := 1 To Len( aIntMnt )
				If !aIntMnt[nB, 1]
					If !lGerOs
						//-- Gera apenas uma Ordem de Servico por bem.
						aRet := NgGeraOs( "C", dDataBase, aIntMnt[nB, 4], cSerMnt,'N','N','N','N')
						//-- Grava a tabela de Viagem X OS para possibilitar o estorno.
						If aRet[1, 1] == "S"
							RecLock("DFX", .T.)
							DFX->DFX_FILIAL := xFilial("DFX")
							DFX->DFX_FILORI := M->DTW_FILORI
							DFX->DFX_VIAGEM := M->DTW_VIAGEM
							DFX->DFX_ORDSRV := aRet[1, 3]
							DFX->DFX_SEQUEN := M->DTW_SEQUEN
							MsUnLock()

							lGerOs := .T. // OS do bem gerada.
						Else
							Aviso(STR0078, aRet[1, 2], {"Ok"}) //Atenção
						EndIf
						//-- Gera as Etapas da OS
						If aRet[1, 1] == "S"
							TmsMntSTQ( aRet[1, 3], aIntMnt[nB, 2]  )
						EndIf
				  	Else
						TmsMntSTQ( aRet[1, 3], aIntMnt[nB, 2]  )
					EndIf
				EndIf
			Next nB
		Next nA
	ElseIf cTipo == '2'
		If !Empty(aItem) //Se for uma prestacao de contas possuo aCols
	      For nA := 1 to Len ( aItem )
	    		nPosFolder := aScan(aFolderBkp,{|x| x[1] +x[2] + x[3]+ x[4] == AllTrim(GdFieldGet('EU_FILORI',nA,,,aItem)) + AllTrim(GdFieldGet('EU_VIAGEM',nA,,,aItem))+;
	 																						AllTrim(GdFieldGet('EU_CODDES',nA,,,aItem)) + AllTrim(GdFieldGet('EU_CODVEI',nA,,,aItem))})
				If !GdDeleted(nA) .And. nPosFolder > 0
		      	lGerOs := .F.
					cFilOri := aFolderBkp[nPosFolder,1]
					cViagem := aFolderBkp[nPosFolder,2]
					If !Empty (aFolderBkp[nPosFolder][4]) // Ordem de serviço for originada por um veículo
						aIntMnt := aClone( aFolderBkp[nPosFolder, 5, 1, 2] )
						For nB := 1 To Len (aIntMnt)
							If aIntMnt[nB, 1] //Manutenção marcada.
								If !lGerOs
									//-- Gera Ordem de Servico.
									aRet := NgGeraOs( "C", dDataBase, aIntMnt[nB, 4], cSerMnt,'N','N','N','N')

									//-- Grava a tabela de Viagem X OS para possibilitar o estorno.
									If aRet[1, 1] == "S"
										RecLock("DIO", .T.)
										DIO->DIO_FILIAL := xFilial("DIO")
										DIO->DIO_INTMOV := SEU->EU_NUM
										DIO->DIO_CODVEI := aIntMnt[nB, 4]
										DIO->DIO_ORDSRV  := aRet[1, 3]
										MsUnLock()

										lGerOs := .T. // OS do bem gerada.
									   If lGerOs
										     // Realiza reporte de insumos.
											lInsumo := NGRETINS( aRet[1, 3],;
												 	    STJ->TJ_PLANO,;
													    "C",;
												          ,; 						//Bem da OS
												          ,;           			//Serviço da OS somente se não for informado o numero da Os e Plano
												          ,;           			//Sequencia da OS somente se não for informado o numero da Os e Plano
												          "0",;					//Código da Tarefa
												          "P",;        			// Tipo de Insumo - P=Produto - M=Funcionário - F= Ferramenta - T=Terceiro
												          cPrdCons,;	//Produto Consumido
												          1,;  		//Quantidade Consumida
												          Posicione("SB1", 1, xFilial("SB1") + cPrdCons, "B1_UM" ),; //Unidade de Consumo
												          "A",; 					//Destino do Consumo
												          STR0213,; 				//Descrição do Serviço Efetuado -- /MANUTENÇÃO
												          dDataBase,;         //Data do Início do Consumo
												          Left( Time(), 5 ),; //Hora de Início do Consumo
												          "E" )               //Gera funcionário ou Especialidade


												//-- Gera as Etapas da OS
												TmsMntSTQ( aRet[1, 3], aIntMnt[nB, 2]  )

												//-- Finaliza a ordem de Serviço
												NGFINAL(STJ->TJ_ORDEM,STJ->TJ_PLANO,STJ->TJ_DTPRINI,STJ->TJ_HOPRINI,;
										  			   STJ->TJ_DTPRFIM,STJ->TJ_HOPRFIM,0,0,aIntMnt[nB, 4],STJ->TJ_HORACO1,STJ->TJ_HORACO2)
									  	EndIf
									Else
										Aviso(STR0078, aRet[1, 2], {"Ok"})
									EndIf
								Else
									//-- Gera as Etapas da OS
									TmsMntSTQ( aRet[1, 3], aIntMnt[nB, 2]  )
								EndIf
							EndIf
						Next nB
					Else // Ordem de serviço for originada por uma viagem
						aIntMnt := aClone( aFolderBkp[nPosFolder, 5] )
						For nB := 1 To Len( aIntMnt )
							lGerOs := .F.
							For nC := 1 To Len (aIntMnt[nB][2])
								If aIntMnt[nB][2][nC][1] //Se a etapa estiver marcada;
									If !lGerOs
										//-- Gera Ordem de Servico.
										aRet := NgGeraOs( "C", dDataBase, aIntMnt[nB,2,nC, 4], cSerMnt,'N','N','N','N')

										//-- Grava a tabela de Viagem X OS para possibilitar o estorno.
										If aRet[1, 1] == "S"
											RecLock("DFX", .T.)
											DFX->DFX_FILIAL := xFilial("DFX")
											DFX->DFX_INTMOV := SEU->EU_NUM
											DFX->DFX_FILORI := cFilOri
											DFX->DFX_VIAGEM := cViagem
											DFX->DFX_ORDSRV  := aRet[1, 3]
											MsUnLock()

											lGerOs := .T. // OS do bem gerada.
										 	If lGerOs
												// Realiza reporte de insumos.
												lInsumo := NGRETINS( aRet[1, 3],;
												          STJ->TJ_PLANO,;
					 										"C",;
												          ,;					//Bem da OS
												          ,;   				//Serviço da OS somente se não for informado o numero da Os e Plano
												          ,;   				//Sequencia da OS somente se não for informado o numero da Os e Plano
												          "0",;				//Código da Tarefa
												          "P",;   				// Tipo de Insumo - P=Produto - M=Funcionário - F= Ferramenta - T=Terceiro
												          cPrdCons,;//Produto Consumindo
												          1,;  				//Quantidade Consumida
												          Posicione("SB1", 1, xFilial("SB1") + cPrdCons, "B1_UM" ),; //Unidade de Consumo
												          "A",; 			//Destino do Consumo
												          STR0213,; 				//Descrição do Serviço Efetuado
												          dDataBase,;         //Data do Início do Consumo
												          Left( Time(), 5 ),; //Hora de Início do Consumo
												          "E" )               //Gera funcionário ou Especialidade

												//-- Gera as Etapas da OS
												TmsMntSTQ( aRet[1, 3], aIntMnt[nB, 2, nC, 2]  )

												//-- Finaliza a ordem de Serviço
												NGFINAL(STJ->TJ_ORDEM,STJ->TJ_PLANO,STJ->TJ_DTPRINI,STJ->TJ_HOPRINI,;
										  			   STJ->TJ_DTPRFIM,STJ->TJ_HOPRFIM,0,0,aIntMnt[nB, 2, nC, 4],STJ->TJ_HORACO1,STJ->TJ_HORACO2)

										  	EndIf

										Else
											Aviso(STR0078, aRet[1, 2], {"Ok"})
										EndIf
									Else
										//-- Gera as Etapas da OS
										TmsMntSTQ( aRet[1, 3], aIntMnt[nB, 2, nC, 2]  )
									EndIf
								EndIf
							Next nC
						Next nB
					EndIf
				EndIf
			Next nA
		Else // Se não é adiantamento não teremos oAcols e so teremos um FolderBkp
			nPosFolder := aScan(aFolderBkp,{|x| x[1] +x[2] + x[3]+ x[4] == AllTrim(M->EU_FILORI) + AllTrim(M->EU_VIAGEM)+;
	 																						AllTrim(M->EU_CODDES) + AllTrim(M->EU_CODVEI)})
			If nPosFolder > 0
	      	lGerOs := .F.
				cFilOri := aFolderBkp[nPosFolder,1]
				cViagem := aFolderBkp[nPosFolder,2]
				If !Empty (aFolderBkp[nPosFolder][4]) //Se for veículo
					aIntMnt := aClone( aFolderBkp[nPosFolder, 5, 1, 2] )
					For nB := 1 To Len (aIntMnt)
						If aIntMnt[nB, 1] //Se a manutenção estiver marcada;
							If !lGerOs
								//-- Gera Ordem de Servico.
								aRet := NgGeraOs( "C", dDataBase, aIntMnt[nB, 4], cSerMnt,'N','N','N','N')
								//-- Grava a tabela de Viagem X OS para possibilitar o estorno.
								If aRet[1, 1] == "S"
									RecLock("DIO", .T.)
									DIO->DIO_FILIAL := xFilial("DIO")
									DIO->DIO_INTMOV := SEU->EU_NUM
									DIO->DIO_CODVEI := aIntMnt[nB, 4]
									DIO->DIO_ORDSRV  := aRet[1, 3]

									MsUnLock()

									lGerOs := .T. // OS do bem gerada.
								   If lGerOs
									     // Realiza reporte de insumos.
										lInsumo := NGRETINS( aRet[1, 3],;
											 	    STJ->TJ_PLANO,;
												    "C",;
											          ,; 						//Bem da OS
											          ,;           			//Serviço da OS somente se não for informado o numero da Os e Plano
											          ,;           			//Sequencia da OS somente se não for informado o numero da Os e Plano
											          "0",;					//Código da Tarefa
											          "P",;        			// Tipo de Insumo - P=Produto - M=Funcionário - F= Ferramenta - T=Terceiro
											          cPrdCons,;	//Produto Consumido
											          1,;  		//Quantidade Consumida
											          Posicione("SB1", 1, xFilial("SB1") + cPrdCons, "B1_UM" ),; //Unidade de Consumo
											          "A",; 					//Destino do Consumo
											          STR0213,; 				//Descrição do Serviço Efetuado -- /MANUTENÇÃO
											          dDataBase,;         //Data do Início do Consumo
											          Left( Time(), 5 ),; //Hora de Início do Consumo
											          "E" )               //Gera funcionário ou Especialidade


											//-- Gera as Etapas da OS
											TmsMntSTQ( aRet[1, 3], aIntMnt[nB, 2]  )

											//-- Finaliza a ordem de Serviço
											NGFINAL(STJ->TJ_ORDEM,STJ->TJ_PLANO,STJ->TJ_DTPRINI,STJ->TJ_HOPRINI,;
									  			   STJ->TJ_DTPRFIM,STJ->TJ_HOPRFIM,0,0,aIntMnt[nB, 4],STJ->TJ_HORACO1,STJ->TJ_HORACO2)
								  	EndIf
								Else
									Aviso(STR0078, aRet[1, 2], {"Ok"})
								EndIf
							Else
								//-- Gera as Etapas da OS
								TmsMntSTQ( aRet[1, 3], aIntMnt[nB, 2]  )
							EndIf
						EndIf
					Next nB
				Else
					aIntMnt := aClone( aFolderBkp[nPosFolder, 5] )
					For nB := 1 To Len( aIntMnt )
						lGerOs := .F.
						For nC := 1 To Len (aIntMnt[nB][2])
							If aIntMnt[nB][2][nC][1] //Se a etapa estiver marcada;
								If !lGerOs
									//-- Gera Ordem de Servico.
									aRet := NgGeraOs( "C", dDataBase, aIntMnt[nB,2,nC, 4], cSerMnt,'N','N','N','N')

									//-- Grava a tabela de Viagem X OS para possibilitar o estorno.
									If aRet[1, 1] == "S"
										RecLock("DFX", .T.)
										DFX->DFX_FILIAL := xFilial("DFX")
										DFX->DFX_INTMOV := SEU->EU_NUM
										DFX->DFX_FILORI := cFilOri
										DFX->DFX_VIAGEM := cViagem
										DFX->DFX_ORDSRV  := aRet[1, 3]
										MsUnLock()

										lGerOs := .T. // OS do bem gerada.
									 	If lGerOs
											// Realiza reporte de insumos.
											lInsumo := NGRETINS( aRet[1, 3],;
											          STJ->TJ_PLANO,;
				 										"C",;
											          ,;						//Bem da OS
											          ,;   					//Serviço da OS somente se não for informado o numero da Os e Plano
											          ,;   					//Sequencia da OS somente se não for informado o numero da Os e Plano
											          "0",;					//Código da Tarefa
											          "P",;   				// Tipo de Insumo - P=Produto - M=Funcionário - F= Ferramenta - T=Terceiro
											          cPrdCons,;//Produto Consumindo
											          1,;  					//Quantidade Consumida
											          Posicione("SB1", 1, xFilial("SB1") + cPrdCons, "B1_UM" ),; //Unidade de Consumo
											          "A",; 					//Destino do Consumo
											          STR0213,; 				//Descrição do Serviço Efetuado
											          dDataBase,;         //Data do Início do Consumo
											          Left( Time(), 5 ),; //Hora de Início do Consumo
											          "E" )               //Gera funcionário ou Especialidade

											//-- Gera as Etapas da OS
											TmsMntSTQ( aRet[1, 3], aIntMnt[nB, 2, nC, 2]  )

											//-- Finaliza a ordem de Serviço
											NGFINAL(STJ->TJ_ORDEM,STJ->TJ_PLANO,STJ->TJ_DTPRINI,STJ->TJ_HOPRINI,;
									  			   STJ->TJ_DTPRFIM,STJ->TJ_HOPRFIM,0,0,aIntMnt[nB, 2, nC, 4],STJ->TJ_HORACO1,STJ->TJ_HORACO2)

									  	EndIf

									Else
										Aviso(STR0078, aRet[1, 2], {"Ok"})
									EndIf
								Else
									//-- Gera as Etapas da OS
									TmsMntSTQ( aRet[1, 3], aIntMnt[nB, 2, nC, 2]  )
								EndIf
							EndIf
						Next nC
					Next nB
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
RestInter()

Return (lGerOs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsMntEsOs³ Autor ³Robson Alves          ³ Data ³24.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Estorna a Ordem de Serviço e sua estapas da OS.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsMntEsOs			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsMntEsOs(cTipo,cFilOri, cViagem, cCodVei, cCodDes, cIntMov)

Local nA		:= 0
Local aRecDel 	:= {}
Local cSeekDFX := ''
Local cSeekDIO := ''
Local cSeekSTQ := ''

Default cFilOri:= ''
Default cViagem:= ''
Default cCodVei:= ''
Default cCodDes:= ''

If cTipo == '2'  //Financeiro : Lancamento de Depesas/Prestacao de Contas
	DT7->( dbSetOrder( 1 ) )
	//-- Exclui as ordens de servicos geradas no lancamento da despesa.
	If ( !Empty( cFilOri ) .And. !Empty( cViagem ) )
		If DT7->( MsSeek( xFilial("DT7") + cCodDes ) ) .And. !Empty( DT7->DT7_CODFAM )
			DFX->( dbSetOrder( 2 ) )
			DFX->( MsSeek( cSeekDFX := xFilial("DFX") + SEU->( EU_FILORI + EU_VIAGEM ) + cIntMov) )

			STJ->( dbSetOrder(1) )
			STQ->( dbSetOrder(1) )

			While !DFX->( Eof() ) .And. DFX->( DFX_FILIAL + DFX_FILORI + DFX_VIAGEM + DFX_INTMOV   == cSeekDFX )

				If STJ->( MsSeek( xFilial("STJ") + DFX->DFX_ORDSRV ) )
					RecLock("STJ", .F.)
					STJ->( dbDelete() )
					MsUnLock()

					Aadd( aRecDel, DFX->(Recno() ) )
				EndIf

				STQ->( MsSeek( cSeekSTQ := xFilial("STQ") + DFX->DFX_ORDSRV ) )
				While !STQ->(Eof()) .And. STQ->(TQ_FILIAL + TQ_ORDEM == cSeekSTQ)
					RecLock("STQ", .F.)
					STQ->( dbDelete() )
					MsUnLock()
					STQ->( dbSkip() )
				EndDo

				DFX->( dbSkip() )
			EndDo

			For nA := 1 To Len( aRecDel )
				DFX->( dbGoto(aRecDel[nA]) )
				RecLock("DFX", .F.)
				DFX->( dbDelete() )
				MsUnLock()
			Next nA

		EndIf
	ElseIf (!Empty(cCodVei))
		If DT7->( MsSeek( xFilial("DT7") + cCodDes ) ) .And. !Empty( DT7->DT7_CODFAM )
			DIO->( dbSetOrder( 1 ) )
			DIO->( MsSeek( cSeekDIO := xFilial("DIO") + cCodVei + cIntMov ) )

			STJ->( dbSetOrder(1) )
			STQ->( dbSetOrder(1) )

			While !DIO->( Eof() ) .And. DIO->( DIO_FILIAL + DIO_CODVEI + DIO_INTMOV   == cSeekDIO )

				If STJ->( MsSeek( xFilial("STJ") + DIO->DIO_ORDSRV ) )
					RecLock("STJ", .F.)
					STJ->( dbDelete() )
					MsUnLock()

					Aadd( aRecDel, DIO->(Recno() ) )
				EndIf

				STQ->( MsSeek( cSeekSTQ := xFilial("STQ") + DIO->DIO_ORDSRV ) )
				While !STQ->(Eof()) .And. STQ->(TQ_FILIAL + TQ_ORDEM == cSeekSTQ)
					RecLock("STQ", .F.)
					STQ->( dbDelete() )
					MsUnLock()
					STQ->( dbSkip() )
				EndDo

				DIO->( dbSkip() )
			EndDo

			For nA := 1 To Len( aRecDel )
				DIO->( dbGoto(aRecDel[nA]) )
				RecLock("DIO", .F.)
				DIO->( dbDelete() )
				MsUnLock()
			Next nA
		EndIf
	EndIf
Else //Tms : Servico de Inspecao
	//-- Exclui as ordens de servicos geradas no apontamento da atividade de inspecao.
	DFX->( dbSetOrder( 1 ) )
	DFX->( MsSeek( cSeekDFX := xFilial("DFX") + DTW->( DTW_FILORI + DTW_VIAGEM + DTW_SEQUEN )  ) )

	STJ->( dbSetOrder(1) )
	STQ->( dbSetOrder(1) )

	While !DFX->( Eof() ) .And. DFX->( DFX_FILIAL + DFX_FILORI + DFX_VIAGEM + DFX_SEQUEN == cSeekDFX )

		If STJ->( MsSeek( xFilial("STJ") + DFX->DFX_ORDSRV ) )
			RecLock("STJ", .F.)
			STJ->( dbDelete() )
			MsUnLock()

			Aadd( aRecDel, DFX->( Recno() ) )

		EndIf
		STQ->( MsSeek( cSeekSTQ := xFilial("STQ") + DFX->DFX_ORDSRV ) )
		While !STQ->(Eof()) .And. STQ->(TQ_FILIAL + TQ_ORDEM == cSeekSTQ)
			RecLock("STQ", .F.)
			STQ->( dbDelete() )
			MsUnLock()
			STQ->( dbSkip() )
		EndDo
		DFX->( dbSkip() )
	EndDo
	For nA := 1 To Len( aRecDel )
		DFX->( dbGoto(aRecDel[nA]) )
		RecLock("DFX", .F.)
		DFX->( dbDelete() )
		MsUnLock()
	Next nA
EndIf

Return ( Nil )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsRdp   ³ Autor ³ Robson Alves          ³ Data ³14.04.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista uma tela com os documentos que poderao ser		      ³±±
±±³			 ³relacionados ao redespachante. 					    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³					                                       	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³	                                                    	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TmsRdp()

Local cCadastro  := STR0079 //"Documentos"
Local aRotOld    := aClone(aRotina)
Local aCampos    := {}
Local nRecnoDUD  := 0

//-- Variaveis para filtro do Browse no DUD
Local aIndexDUD  := {}
Local	cFiltraDUD := ""
Local	bFiltraBrw := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   aRotina  	:= {}
Local   cTipTra  	:= M->DFT_TIPTRA
Private nOpcSel  	:= 0
Private cSerTms  	:= StrZero( 3, Len( DUD->DUD_SERTMS ) ) //-- Documento de Entrega

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aCampos, "DUD_FILDOC")
AAdd(aCampos, "DUD_DOC")
AAdd(aCampos, "DUD_SERIE")
AAdd(aCampos, "DUD_REGDES")

AAdd( aRotina, { STR0001,"TMSConfSel",0,2,,,.T.} ) // "&Confirmar"

//-- Verifica se devera apresentar a tela para marcar documentos.
DUD->(dbSetOrder(6)) //-- DUD_FILIAL+DUD_FILORI+DUD_SERTMS+DUD_TIPTRA+DUD_STATUS+DUD_VIAGEM
cFiltraDUD := "DUD_FILIAL=='"+xFilial("DUD")+"'.And.DUD_SERTMS=='"+cSerTms+"'.And.DUD_TIPTRA=='"+cTipTra+"'.And.Empty(DUD_VIAGEM).And.DUD_STATUS=='1'.And.DUD_FILORI=='"+cFilAnt+"' .And. Empty(DUD_NUMRED)"
bFiltraBrw := {|| FilBrowse("DUD",@aIndexDUD,@cFiltraDUD) }
Eval(bFiltraBrw)
MaWndBrowse(0,0,300,600,cCadastro,"DUD",aCampos,aRotina,,,,.T.)
nRecnoDUD := DUD->(Recno())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("DUD",aIndexDUD)

aRotina := aClone(aRotOld)

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSConsDUY³ Autor ³ Richard Anderson      ³ Data ³ 04/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe browse das regiões por pais                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSConsDUY()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsConsDUY()

Local   cCadastro  := 'Regiões'
Local   aRotOld    := Iif(Type('aRotina') == 'A',AClone(aRotina),{})
Local   aCampos    := {}
Local   aIndexDUY  := {}
Local   cFiltraDUY := ''
Local   bFiltraBrw := {}
Local   nRecnoDUY  := 0
Local   cPais      := Iif(Type('M->A1_PAIS') == 'C',M->A1_PAIS,'')
Private nOpcSel    := 0

aRotina := {}
AAdd( aRotina, { STR0001 ,"TMSConfSel",0,2,,,.T.} ) // "&Confirmar"

DA8->(dbSetOrder(1))
cFiltraDUY := "DUY_FILIAL=='"+xFilial("DUY")+"'"
If !Empty(cPais)
	cFiltraDUY += ".And.DUY_PAIS=='"+cPais+"'"
EndIf
bFiltraBrw := {|| FilBrowse("DUY",@aIndexDUY,@cFiltraDUY) }
Eval(bFiltraBrw)

MaWndBrowse(0,0,300,600,cCadastro,"DUY",aCampos,aRotina,,,,.T.,,,,,,.F.)

nRecnoDUY := DUY->(Recno())
aRotina   := AClone(aRotOld)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("DUY",aIndexDUY)

DUY->(dbGoTo(nRecnoDUY))

Return( nOpcSel == 1 )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DtValid   ºAutor  ³Microsiga           º Data ³  10/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Calcula a data fiscal valida                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpD1 := DATAVAL(ExpD2,ExpL1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data devolvida pela funcao                         ³±±
±±³          ³ ExpD2 = Data para iniciar calculo da funcao                ³±±
±±³          ³ ExpL1 = .T. posterga a data recebida para proximo dia util ³±±
±±³          ³       = .F. retrocede data recebida para dia util anterior ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DtValid(dData,lProxima)

Local cAlias	:= Alias()
Local nSavRec
Local cData		:= "", cAno := ""
Local dFeriado	:= dDatabase, dDataAnt, nAno
Local cPulaDia	:= ''
Local aFeriados
Local nX
Local nI
Local aDados

lProxima:= Iif(lProxima==Nil,.T.,lProxima)
If	aFeriados == Nil
	aFeriados := {}

	If lSabFeri == NIL   //variavel static para ler apenas uma unica vez
		lSabFeri := If( Alltrim(GETMV("MV_SABFERI")) $ "S",.T.,.F. )
	Endif

	If lDomFeri == NIL  //variavel static para ler apenas uma unica vez
		//-- Se considera o domingo como feriado.
		lDomFeri := ( Alltrim(GetMV('MV_DOMFERI', , "N"))=="S" )
	EndIf

	If ( ValType( dData ) # "D" ) .Or. ( Empty( dData ) )
		dData := dDataBase
	Endif

	If ValType( lProxima ) # "L"
		lProxima := .T.
	Endif

	If aSX5Tab63 == NIL  //variavel static para ler tabela 63 uma unica vez
		aSX5Tab63 := {}
		nSavRec	:= SX5->( Recno() )
		aDados:= FWGetSX5('63')
		For nI:=1 to Len(aDados)
			aAdd(aSX5Tab63, { Subst(aDados[nI][4],1,2), Subst(aDados[nI][4],4,2), Subst(aDados[nI][4],7,2) } )
		next
		SX5->( dbGoTo(nSavRec) )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Varre a tabela de feriados para verificar se a data   ³
	//³ base ‚ feriado.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 TO Len(aSX5Tab63)
		cData := aSX5Tab63[nX,1] + '/' + aSX5Tab63[nX,2]
		cAno  := aSX5Tab63[nX,3]
		If Empty(cAno)
			nAno := Year(dData)
			cAno := Subs(StrZero(nAno,4,0),3,2)
			dFeriado := ctod( cdata+"/"+cAno,"DDMMYY" )
			aAdd(aFeriados,dTos(dFeriado))
			nAno -= 1
			cAno := Subs(StrZero(nAno,4,0),3,2)
			dFeriado := ctod( cdata+"/"+cAno,"DDMMYY" )
			aAdd(aFeriados,dTos(dFeriado))
			nAno += 2
			cAno := Subs(StrZero(nAno,4,0),3,2)
			dFeriado := ctod( cdata+"/"+cAno,"DDMMYY" )
			aAdd(aFeriados,dTos(dFeriado))
		Else
			cData += ("/" + cAno)
			dFeriado := ctod( cdata,"DDMMYY" )
			aAdd(aFeriados,dTos(dFeriado))
		EndIf
	Next //nX
	aFeriados:=aSort(aFeriados)
EndIf

If lSabFeri
	cPulaDia += "7"
EndIf
If lDomFeri
	cPulaDia += "1"
EndIf

dDataAnt := Ctod("  /  /  ")
While dDataAnt != dData
	dDataAnt := dData
	If StrZero(Dow(dData),1,0) $ cPulaDia .Or. aScan(aFeriados,DTOS(dData)) > 0
		If lProxima
			dData++
		Else
			dData--
		EndIf
	EndIf
EndDo

If !Empty( cAlias )
	dbSelectArea( cAlias )
EndIf
Return( dData )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSXFUNA_V ³ Autor ³ Raspa                ³ Data ³ 05.Jun.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para verificar a ultima versao do fonte   ³±±
±±³			 ³ TMSXFUNA.PRW aplicado nO RPO do cliente, assim verificando ³±±
±±³			 ³ a necessidade de uma atualizacao neste fonte.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS - GESTAO DE TRANSPORTES                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSXFUNA_V()
Local nRet := 20090605 // 05 de Junho de 2009
Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmsPrimSup   ºAutor  ³Paulo Carnelossi   º Data ³ 18/04/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que popula tabela temporaria no banco com conteudo   º±±
±±º          ³CAMPOS - ANALITICA || SUPERIOR                              º±±
±±º          ³ROTINA INICIAL                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TmsPrimSup(cAlias, nOrdem, bSeek, bWhile, bCond, bAtual, bSuperior, bLeftWhile, bCondRecursiv, bExecute, cArquivo )

dbSelectArea(cAlias)
dbSetOrder(nOrdem)

Eval(bSeek)

While (cAlias)->( ! Eof() .And. Eval(bWhile) )

	If (cAlias)->(Eval(bCond))
		TmsSuperiores( cAlias, nOrdem, Eval(bAtual), Eval(bSuperior), bSuperior, bLeftWhile, bCondRecursiv, bExecute, cArquivo)
	EndIf

	dbSelectArea(cAlias)
	dbSkip()
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmsSuperioresºAutor  ³Paulo Carnelossi   º Data ³ 18/04/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que popula tabela temporaria no banco com conteudo   º±±
±±º          ³CAMPOS - REGIAO || SUPERIOR                                 º±±
±±º          ³Recursiva para chegar ao topo da REGIAO superior            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TmsSuperiores( cAlias, nOrdem, cAtual, cSuperior, bSuperior, bLeftWhile, bCondRecursiv, bExecute, cArquivo)
Local aArea := GetArea()

dbSelectArea(cAlias)
dbSetOrder(nOrdem)

MsSeek(xFilial()+cSuperior)

While (cAlias)->( ! Eof() .And. Eval(bLeftWhile) == xFilial()+cSuperior )

	Eval(bExecute, cArquivo, cAtual, cSuperior)

	If Eval(bCondRecursiv)
		TmsSuperiores( cAlias, nOrdem, cAtual, Eval(bSuperior), bSuperior, bLeftWhile, bCondRecursiv, bExecute, cArquivo)
	Else
		Exit  //chegou ao topo
	EndIf

	dbSelectArea(cAlias)
	dbSkip()

End

RestArea(aArea)

Return NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmsInsTab        ºAutor ³Paulo Carnelossi º Data ³ 18/04/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que popula tabela temporaria no banco com conteudo   º±±
±±º          ³CAMPOS - REGIAO || SUPERIOR                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TmsInsTab(cArquivo, cAtual, cSuperior)
Local aArea := GetArea()

dbSelectArea(cArquivo)

RecLock(cArquivo, .T.)
(cArquivo)->REGIAO   := cAtual
(cArquivo)->SUPERIOR := cSuperior
MsUnLock()

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³My_Posicione ºAutor  ³Microsiga        º Data ³  24/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para manter em cache os recnos utilizadas para       º±±
±±º          ³substituir a funcao posicione originalmente chamada         º±±
±±º          ³o cache sera mantido no array STATIC aAuxPosic              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function My_Posicione(cAlias,nOrdem,cChave,cCampoRet)
Local nPos := 0
Local cAuxFil := cEmpAnt+cFilAnt+xFilial(cAlias)
Local nOrdAux := StrZero(nOrdem,2)
Local xRetorno

(cAlias)->( dbSetOrder(nOrdem) )

If ( nPos := aScan(aAuxPosic,{|x|x[1]+x[2]+x[3]+x[4]==cAuxFil+cAlias+nOrdAux+cChave}) ) > 0
    (cAlias)->( dbGoto(aAuxPosic[nPos, 5]) )
    xRetorno := &(cAlias+"->("+cCampoRet+")")
Else
	If	(cAlias)->(MsSeek(cChave))
		aAdd(aAuxPosic, { cAuxFil, cAlias, nOrdAux, cChave, (cAlias)->(Recno()) } )
	EndIf
	xRetorno := &(cAlias+"->("+cCampoRet+")")
EndIf

Return(xRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsPosAtu ³ Autor ³Caio Murakami          ³ Data ³23.05.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a ultima posicao do veiculo - Tabela DAV            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsPosAtu()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Codigo do veiculo, Codigo da viagem                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS - GESTAO DE TRANSPORTES                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TmsPosAtu( cCodVei , cFilOri , cViagem , cFilDoc , cDoc , cSerie )
Local aPosici     := Array(3)//-- Array fixo para manter a estrututa caso nao encontre registros
Local cAliasQry 	:= GetNextAlias()
Local cQuery		:= ""
Local aArea			:= GetArea()
Local lDocDT6		:= .F.
Local cHorPos		:= ""
Local dDatPos		:= CtoD("")

Local lExibPosic  := .T.
Local aAuxPosici	:= {}
Local aAreaDUD		:= DUD->( GetArea() )
Local aAreaDT6		:= DT6->( GetArea() )
Local aAreaDTW		:= DTW->( GetArea() )
Local cAtivChg		:= GetMV('MV_ATIVCHG',,'')
Local nRecDAV		:= 0

Default cCodVei 	:= ""
Default cFilOri	:= ""
Default cViagem	:= ""
Default cHorPos	:= ""
Default cFilDoc	:= ""
Default cDoc		:= ""
Default cSerie		:= ""

If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
   lExibPosic := .F.
   DT6->( dbSetOrder(1) )
   If DT6->( MsSeek( xFilial("DT6") + cFilDoc + cDoc + cSerie ) )

   	lDocDT6 	:= .T.
   	cFilOri 	:= DT6->DT6_FILVGA
   	cViagem	:= DT6->DT6_NUMVGA

	   //-----------------------------------------------------------------
		/*
			DT6_STATUS == '1' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'1') //-- Em aberto
			DT6_STATUS == '2' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'2') //-- Carregado ### Indicado para Coleta
			DT6_STATUS == '3' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'3') //-- Em transito
			DT6_STATUS == '4' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'5') //-- Chegada parcial ### Documento Informado
			DT6_STATUS == '5' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'4') //-- Chegada final   ### Encerrada
			DT6_STATUS == '6'	//-- Indicado p/ entrega
			DT6_STATUS == '7'	//-- Entregue
			TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'9')	//-- Ordem de Coleta Cancelada
			DT6_STATUS == '8'	//Entrega Parcial
			DT6_STATUS == '9'//Anulado
			DT6_STATUS == 'A'	//Retorno Total
		*/
	 	//-----------------------------------------------------------------

	 	If DT6->DT6_DOCTMS == '1' //-- Ordem de Coleta

	 		If DT6->DT6_STATUS == '1' .Or. TMSStatCol(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,'1') .Or. ;
	 			DT6->DT6_STATUS == '2' .Or. TMSStatCol(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,'2') .Or. ;
	 			DT6->DT6_STATUS == '3' .Or. TMSStatCol(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,'3')

	 			lExibPosic	 := .T.


	 		ElseIf ( DT6->DT6_STATUS == '5' .And. DT6->DT6_SERIE <> 'COL' ) .Or. TMSStatCol( DT6->DT6_FILDOC , DT6->DT6_DOC , DT6->DT6_SERIE ,'4')

	 			lExibPosic	:= .T.

	 	      //-- Busca ocorrencias do tipo encerra processo
	 	      aAuxPosici := TMSVerOco(DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE , DT6->DT6_SERTMS, '01' , , )

	 	      If Len(aAuxPosici) > 0
	 	         If Len(aAuxPosici[1]) > 2
		 	      	dDatPos	:= aAuxPosici[Len(aAuxPosici),3]
		 	      	cHorPos	:= aAuxPosici[Len(aAuxPosici),4]
		 	     EndIf
	 	      EndIf

	 		EndIf
		Else

			If DT6->DT6_STATUS == '1' .Or. TMSStatCol(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,'1') .Or. ;
	 			DT6->DT6_STATUS == '2' .Or. TMSStatCol(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,'2') .Or. ;
	 			DT6->DT6_STATUS == '3' .Or. TMSStatCol(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,'3') .Or. ;
	 			DT6->DT6_STATUS == '6'

	 			lExibPosic	 := .T.

	 		ElseIf  DT6->DT6_STATUS == '4'  .Or. TMSStatCol( DT6->DT6_FILDOC , DT6->DT6_DOC , DT6->DT6_SERIE , '5')

	 			lExibPosic	 := .T.
	 			//-- DATA E HORA DA CHEGADA NA FILIAL DE DESCARGA DUD_FILDCA
	 			DUD->( dbSetOrder(1) )
	 			If DUD->( MsSeek( xFilial("DUD") + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE + DT6->DT6_FILVGA + DT6->DT6_NUMVGA ) )
	 				DTW->( dbSetOrder(4) ) //-- DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
	 				If DTW->( MsSeek( xFilial("DTW") + DT6->DT6_FILVGA + DT6->DT6_NUMVGA + cAtivChg + DUD->DUD_FILDCA ) )
	 					dDatPos 	:= DTW->DTW_DATREA
	 	        		cHorPos	:= DTW->DTW_HORREA
	 				EndIf
	 			EndIf

	 		ElseIf  DT6->DT6_STATUS == '5' .Or. TMSStatCol( DT6->DT6_FILDOC , DT6->DT6_DOC , DT6->DT6_SERIE , '4')
	 			lExibPosic	:= .T.

	 	      //-- DATA E HORA DA CHEGADA NA FILIAL DESTINO DT6_FILDES
	 			DTW->( dbSetOrder(4) ) //-- DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
	 			If DTW->( MsSeek( xFilial("DTW") + DT6->DT6_FILVGA + DT6->DT6_NUMVGA + cAtivChg + DT6->DT6_FILDES ) )
	 				dDatPos 	:= DTW->DTW_DATREA
	 	     		cHorPos	:= DTW->DTW_HORREA
	 			EndIf

	 		ElseIf ( DT6->DT6_STATUS == '7' .Or. DT6->DT6_STATUS == '8'  )
	 	    	//-- DATA E HORA DA OCORRENCIA DE ENCERRA PROCESSO
	 	    	lExibPosic	:= .T.

	 	    	//-- Busca ocorrencias do tipo "01 - Encerra Processo"
	 	      aAuxPosici := TMSVerOco(DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE , DT6->DT6_SERTMS, '01' , , )
	 	      If Len(aAuxPosici) > 0
	 	         If Len(aAuxPosici[1]) > 2
		 	      	dDatPos	:= aAuxPosici[Len(aAuxPosici),3]
		 	      	cHorPos	:= aAuxPosici[Len(aAuxPosici),4]
		 	     EndIf
	 	      EndIf

	 	 	ElseIf DT6->DT6_STATUS == 'A'
	 	 	 	//	<= 'DATA E HORA DA OCORRENCIA DE RETORNO'
	 	 	 	lExibPosic	:= .T.

	 	 	 	//-- Busca ocorrencias do tipo "04 - Retorna Documento"
	 	      aAuxPosici := TMSVerOco(DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE , DT6->DT6_SERTMS, '04' , , )
	 	      If Len(aAuxPosici) > 0
	 	         If Len(aAuxPosici[1]) > 2
		 	      	dDatPos	:= aAuxPosici[Len(aAuxPosici),3]
		 	      	cHorPos	:= aAuxPosici[Len(aAuxPosici),4]
		 	     EndIf
	 	      EndIf

	 		EndIf
	 	EndIf
   EndIf
EndIf

If lExibPosic

	cQuery := " SELECT MAX(R_E_C_N_O_) DAVRECNO "
	cQuery += " FROM "+RetSqlName('DAV')+" DAV "
	cQuery += " WHERE DAV_FILIAL 				= '" + xFilial("DAV") + "' "
	If !Empty(cCodVei)
		cQuery += " 		AND DAV_CODVEI 		= '" + cCodVei + "' "
	EndIf
	If !Empty(cFilOri)
		cQuery += " 		AND DAV_FILORI 		= '" + cFilOri + "' "
	EndIf
	If !Empty(cViagem)
		cQuery += " 		AND DAV_VIAGEM 		= '" + cViagem + "' "
	EndIf
	If !Empty(dDatPos)
		cQuery += "		AND DAV_DATPOS <= '" + dToS(dDatPos) + "' "
	EndIf
	cQuery += "			AND DAV.D_E_L_E_T_ 	= ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->(!Eof())
		nRecDAV := (cAliasQry)->DAVRECNO
		DAV->( dbGoTo( nRecDAV ))
		aPosici := {dToC(DAV->DAV_DATPOS) , DAV->DAV_HORPOS , DAV->DAV_DETPOS }
	EndIf

	(cAliasQry)->(dbCloseArea())

	If nRecDAV > 0 .And. !Empty(cHorPos) .And. !Empty(cViagem)
		DAV->(dbGoTo(nRecDAV))
		dDatPos := DAV->DAV_DATPOS
		cQuery := " SELECT MAX(R_E_C_N_O_) DAVRECNO "
		cQuery += " FROM "+RetSqlName('DAV')+" DAV "
		cQuery += " WHERE DAV_FILIAL 		 = '" + xFilial("DAV") + "' "
		If !Empty(cCodVei)
			cQuery += " 		AND DAV_CODVEI 		= '" + cCodVei + "' "
		EndIf
		cQuery += "   AND DAV_FILORI 		 = '" + cFilOri + "' "
		cQuery += "   AND DAV_VIAGEM 		 = '" + cViagem + "' "
		cQuery += "	  AND DAV_DATPOS      = '" + dToS(dDatPos) + "' "
		cQuery += "   AND DAV_HORPOS		<= '" + cHorPos + "' "
		cQuery += "	  AND DAV.D_E_L_E_T_  = ' '  "

		cQuery := ChangeQuery(cQuery)
  		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

		If (cAliasQry)->(!Eof())
			nRecDAV := (cAliasQry)->DAVRECNO
			DAV->( dbGoTo( nRecDAV ))
			aPosici := {dToC(DAV->DAV_DATPOS) , DAV->DAV_HORPOS , DAV->DAV_DETPOS }
		EndIf

		(cAliasQry)->(DbCloseArea())
	EndIf
EndIf

RestArea( aAreaDTW )
RestArea( aAreaDT6 )
RestArea( aAreaDUD )
RestArea( aArea )

Return ( aPosici )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |TMSLatLong³ Autor ³Caio Murakami          ³ Data ³19.12.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna coordenada no formato adequado de acordo com picture³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsLatLong()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³       																	  ³±±
±±³			 ³	ExpC1 = Latitude ou Longitude                              ³±±
±±³          ³ ExpD2 = Indica se o retorno sera a picture utilizada ou    ³±±
±±³          ³         latitude e longitude apos o tratament              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/


Function TMSLatLong( cLatLong  )
Local cRet 		:= ""
Local cPicture := PesqPict('DAV','DAV_LATITU')
Local cInt		:= "" //-- Variavel ira armazenar o valor inteiro da coordenada
Local cDec		:= "" //-- Variavel ira armazenar o valor decimal da coordenada
Local nTamInt	:= 0 	//-- Numero de casas inteiras de acordo com picture
Local nTamDec	:= 0  //-- Numero de casas decimais de acordo com picture

Default cLatLong := ""

cLatLong := StrTran( cLatLong, ',' , '.' )
nTamInt 	:= At('.',cPicture) - 1
nTamDec  := Len(cPicture) - At('.',cPicture)

If At('.', cLatLong) <> 0
	cInt     := SubStr( cLatLong , 1 , At('.', cLatLong) - 1 )
	cInt 		:= StrZero( Val(cInt) , nTamInt )

   cDec		:= SubStr( cLatLong , At( '.', cLatLong )  , Len(cLatLong) )
   cDec		:= StrTran( cDec , ' '  , '0' )

	cRet		:= Transform(cInt + cDec , cPicture )
Else
   cLatLong	:= StrZero( Val(cLatLong) , nTamInt )
   cLatLong	:= StrTran( cLatLong, ' ', '0' )
   cRet 		:= Transform(cLatLong,cPicture)
EndIf


Return cRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    TMSAptJus Autor ³Caio Murakami             ³ Data ³21.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Função para realizar a inclusão de registros pendentes de   ³±±
±±³  				justificativa - DAY          							           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAptJus()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³       																	  ³±±
±±³          ³ ExpC1 = Codigo do motorista                                ³±±
±±³			 ³	ExpC2 = Codigo do apontamento da jornada              	 ³±±
±±³			 ³	        (IJ,FJ,IR,FR,ID,FD,IV,FV)                       	 ³±±
±±³			 ³	ExpC3 = Filial de Origem                              	 ³±±
±±³			 ³	ExpC4 = Codigo da Viagem                              	 ³±±
±±³			 ³	ExpD1 = Data do apontamento                           	 ³±±
±±³          ³ ExpC5 = Hora do apontamento                                ³±±
±±³          ³ ExpC6 = Hora de atraso                                     ³±±
±±³          ³ ExpC7 = Parametro de atraso                                ³±±
±±³          ³ ExpC8 = Motivo de atraso                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAO35                                                    ³±±
±±³          ³ 		                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMSAptJus(cCodMot , cAptJor , cFilOri , cViagem , dDatApt , cHorApt , cParDEY , cMotApt, lDel )

Local aCab 		 := {}
Local lGrvOk	 := .F.
Local aArea		 := GetArea()
Local cRet		 := "0" 	//-- 0=Não gravou;1=Justificativa analisada;2=Pendente de Analise
Local cPAptoJF  := SuperGetMV('MV_PAPTOJF', , "0") //-- Exibe Pergunta apontamento da justificativa
Local cSeekDAY  := ""

Default cCodMot := ""
Default cAptJor := ""
Default cFilOri := ""
Default cViagem := ""
Default dDatApt := CtoD("")
Default cHorApt := ""
Default cParDEY := ""
Default cMotApt := ""

//-- Verifica se o apontamento das jusitifcativas pendentes ainda existe
//-- Caso não exista, exclui a justificativa pendente
DEW->(dbSetOrder(1))
DAY->(dbSetOrder(3))
DAY->(dbSeek(cSeekDAY := xFilial('DAY')+cCodMot+'2'))
While DAY->(!Eof()) .And. DAY->(DAY_FILIAL+DAY_CODMOT+DAY_STATUS) == cSeekDAY
	If DEW->(!dbSeek(xFilial('DEW')+DAY->(DAY_CODMOT+DAY_APTJOR+DToS(DAY_DATAPT)+DAY_HORAPT)))
		RecLock('DAY',.F.)
		dbDelete()
		MsUnLock()
	EndIf
	DAY->(dbSkip())
EndDo

DAY->( dbSetOrder(1) )
If DAY->(! MsSeek( xFilial("DAY") + cCodMot + cAptJor + DToS(dDatApt) + cHorApt ) ) .And. !lDel
	Aadd( aCab , {	"DAY_CODMOT",	cCodMot				,	Nil	} )
	Aadd( aCab , {	"DAY_FILORI",	cFilOri				,	Nil	} )
	Aadd( aCab , {	"DAY_VIAGEM", 	cViagem				,	Nil	} )
	Aadd( aCab , {	"DAY_DATAPT",	dDatApt				,	Nil	} )
	Aadd( aCab , {	"DAY_HORAPT",	cHorApt				,	Nil	} )
	Aadd( aCab , {	"DAY_APTJOR",	cAptJor        	,	Nil	} )
	Aadd( aCab , {	"DAY_CODPAR",	cParDEY				,	Nil	} )
	Aadd( aCab , {	"DAY_MOTAPT",	cMotApt				,	Nil	} )

	lGrvOk := TMSMdlAuto( aCab ,, 3 , "TMSAO41" , "MdFieldDAY" ,, "DAY" , .F.  )

	If lGrvOk .And. cPAptoJF == "1" .And. TmsAcesso(,"TMSAO41",,3)
		If MsgYesNo( STR0266  , STR0265 ) //-- Foi gerada uma pendencia para o motorista, deseja justificar agora?

			oModel := FWLoadModel( "TMSAO41" )
			oModel:SetOperation( 4 ) // Alteracao
			oModel:Activate() // Ativa o modelo com os dados posicionados

			oModel:GetModel( "MdFieldDAY" ):SetValue( "DAY_STATUS", "1" )

			//-- Se clicou em confirmar
			//-- 1=Justificado;2=Pendente
			If FWExecView(STR0267 , 'TMSAO41', 4, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )	== 0
				cRet := "1"
			Else
				cRet := "2"
			EndIf
		Else
			cRet := "2"
		EndIf
	EndIf
Else
	If lDel
		oModel := FWLoadModel( "TMSAO41" )
		oModel:SetOperation( 5 ) //-- Exclusão
		oModel:Activate() //-- Ativa o modelo com os dados posicionados

		lRet := oModel:VldData()
		If lRet
			lRet := oModel:CommitData()
		Else
			cRet := "ERROR"
		EndIf
	Else
		cRet := DAY->DAY_STATUS
	EndIf
EndIf

RestArea( aArea )

Return cRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    TMSAptJor Autor ³Caio Murakami             ³ Data ³21.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Função para realizar a inclusão de registros pendentes de   ³±±
±±³  				justificativa - DAY          					       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAptJor()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³       													  ³±±
±±³          ³ ExpC1 = Codigo do motorista                                ³±±
±±³			 ³	ExpC2 = Codigo do apontamento da jornada              	 ³±±
±±³			 ³	        (IJ,FJ,IR,FR,ID,FD,IV,FV)                       ³±±
±±³			 ³	ExpC3 = Filial de Origem                              	 ³±±
±±³			 ³	ExpC4 = Codigo da Viagem                              	 ³±±
±±³			 ³	ExpD1 = Data do apontamento                           	 ³±±
±±³          ³ ExpC5 = Hora do apontamento                                ³±±
±±³          ³ ExpC6 = Hora de atraso                                     ³±±
±±³          ³ ExpC7 = Parametro de atraso                                ³±±
±±³          ³ ExpC8 = Motivo de atraso                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAO35                                                    ³±±
±±³          ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMSAptJor( cCodMot , cAptJor , dData , cHora , cFilOri , cViagem , cObsApt)
Local aArea 	:= GetArea()
Local aAreaDA4 	:= DA4->( GetArea() )
Local aCab		:= {}
Local aItens   	:= {}
Local lOk		:= .F.

Default dData 		:= dDataBase
Default cHora 		:= Left( Time() , 5 )
Default cFilOri   	:= ""
Default cViagem		:= ""
Default cObsApt 	:= ""

cHora := StrTran(cHora , ":" , "" )

//-- Posiciona no motorista
DA4->( dbSetOrder(1) )
If DA4->( MsSeek( xFilial("DA4") + cCodMot ) )

  	Aadd( aCab 		, {"DA4_COD" 	, cCodMot	, Nil } ) //-- Codigo do motorista

	//-- Array de itens
	Aadd( aItens, {} )
	Aadd( aItens[Len(aItens)], {"DEW_APTJOR", cAptJor 		, Nil } ) //-- Apontamento (IJ FJ IV FV IR FR ID FD )
	Aadd( aItens[Len(aItens)], {"DEW_DATAPT", dData 		, Nil } ) //-- Data
	Aadd( aItens[Len(aItens)], {"DEW_HORAPT", cHora			, Nil } ) //-- Hora
	Aadd( aItens[Len(aItens)], {"DEW_FILORI", cFilOri 		, Nil } ) //-- Filial de Origem
	Aadd( aItens[Len(aItens)], {"DEW_VIAGEM", cViagem 		, Nil } ) //-- Viagem
	Aadd( aItens[Len(aItens)], {"DEW_TIPAPT", "2"			, Nil } ) //-- Apontamento automatico
	Aadd( aItens[Len(aItens)], {"DEW_OBSAPT", cObsApt		, Nil } ) //-- Observacao do apontamento

	DEW->( dbSetOrder(1) )
	IF !DEW->( MsSeek( xFilial("DEW") + cCodMot + cAptJor + DToS( dData ) + cHora ) )
		//-- Gravacao no model ( Operacao sempre de alteracao, pois o motorista já existe e herdamos a classe OMSA040_DA4 )
		lOk := TMSMdlAuto( aCab , aItens , 4 , "TMSAO35" , "OMSA040_DA4" , "MdGridDEW" , "DA4" , "DEW" )
    EndIf
EndIf

RestArea( aAreaDA4 )
RestArea( aArea    )
Return lOk



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    TMSMdlAuto Autor ³Caio Murakami          ³ Data ³18.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa operacoes do model pai/filho                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSMdlAuto()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³       																	  ³±±
±±³          ³ ExpA1 = Array com campos e valores do cabecalho            ³±±
±±³          ³ ExpA2 = Array com campos e valores do grid                 ³±±
±±³          ³ ExpN1 = Operacao do modelo                                 ³±±
±±³          ³ ExpC1 = Nome do Model                                      ³±±
±±³			 ³	ExpC2 = Nome do model cabecalho (FIELD)                    ³±±
±±³          ³ ExpC3 = Nome do model detalhe   (GRID)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAO35                                                    ³±±
±±³          ³ TMSA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMSMdlAuto( aCpoMaster , aCpoDetail , nOpc , cModel , cMaster , cDetail , cAliasMast , cAliasGrid , lExibErro, cMsgErr)
Local aMaster	:= {}
Local aGrid		:= {} 
Local aArea		:= GetArea()

Default aCpoMaster	:= {}
Default aCpoDetail	:= {}
Default nOpc		:= 3 
Default cModel		:= ""
Default cDetail 	:= ""
Default cAliasMast	:= ""
Default cAliasGrid	:= ""
Default lExibErro	:= .T.
Default cMsgErr   	:= ""

Aadd( aMaster , {} )
Aadd( aMaster[Len(aMaster)] , aClone(aCpoMaster) )
Aadd( aMaster[Len(aMaster)] , cMaster )
Aadd( aMaster[Len(aMaster)] , cAliasMast )

If Len( aCpoDetail ) > 0 
	Aadd( aGrid , {} )
	Aadd( aGrid[Len(aGrid)] , aClone(aCpoDetail) )
	Aadd( aGrid[Len(aGrid)] , cDetail )
	Aadd( aGrid[Len(aGrid)] , cAliasGrid )
EndIf 

lRet	:= TMSExecAuto( cModel ,  aClone(aMaster)  , aClone(aGrid),  nOpc  , lExibErro, cMsgErr )

RestArea( aArea )
Return lRet

/*{Protheus.doc} TMSExecAuto
    Função criada com o objetivo de realizar operações no modelo de dados sem interface
	A função deve substituir a tmsmdlauto, com a melhoria de prever N arrays de itens.
	Podendo efetuar a inclusão,alteração e exclusão de modelos com mais de 1 grid.
    @type Function
    @author Caio Murakami
    @since 03/09/2020
    @version P12 R12.1.29
    @param cModel 	, character	, Nome do modelo a ser emulado
	@param aMaster	, array 	, {{ aCab, Nome do Field, Tabela }}
	@param aItens 	, array 	, { { aGrid1, Nome do Grid, Tabela } , { aGrid2, Nome do Grid, Tabela }  }
	@param nOpc   	, numeric  	, 3-Inclusão;4-Alteração;5-Exclusão
	@param lExibErro, logical	, .T. para exibir a mensagem de erro em tela, .F. sem mesagem em tela
	@param cMsg   	, character , Mensagem adicional a ser exibida 
    @return lRet	, logical	, Indica se a operação foi efetuada com sucesso
    @example TMSAF60()
    (examples)
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=269552294
	@see https://tdn.totvs.com/pages/viewpage.action?pageId=269552736
*/
Function TMSExecAuto( cModel,  aMaster, aItens,  nOpc, lExibErro, cMsgErr )
Local aArea		:= GetArea()
Local oModel	:= Nil
Local oAux		:= Nil
Local oStruct	:= Nil
Local nPos 		:= 0
Local lRet 		:= .T.
Local aAux 		:= {}
Local lAux 		:= .T.
Local lGrid		:= .F.
Local aMsgErr   := {}
Local nCount    := 0
Local nAux1     := 0 
Local nAux2     := 0 
Local nErro     := 0 
Local aErro     := {}
Local aCpoMaster:= {}
Local cAliasMast:= ""
Local cMaster   := ""
Local cAliasAux := ""
Local nLinGrid  := 0

Local lPesqLine := .F.
Local lFindLine := .F.
Local aPesqLine := {}
Local aChvUnq   := {}
Local nCntFor1  := 0
Local nPosCpo   := 0
Local nLinAlt   := 0

Default cModel      := ""
Default cDetail 	:= ""
Default aMaster	    := {}
Default aItens      := {} 
Default lExibErro	:= .T.
Default cMsgErr   	:= ""

oModel := FWLoadModel( cModel )
oModel:SetOperation( nOpc )
oModel:Activate()

If Len(aMaster) > 0 
	
	lGrid	:= Len(aItens) > 0 

	For nCount := 1 To Len(aMaster)
		aCpoMaster  := aMaster[nCount,1]
		cMaster     := aMaster[nCount,2]
		cAliasMast  := aMaster[nCount,3]

		DbSelectArea( cAliasMast )
		DbSetOrder( 1 )

		oAux    := oModel:GetModel( cMaster  )
		oStruct := oAux:GetStruct()
		aAux 	:= oStruct:GetFields()
		
		If lRet .And. nOpc <> 5 .And. ;
			 ( ( nOpc == 3 ) .Or. ( nOpc == 4 .And. !lGrid  ) .Or. ( nOpc == 4 .And. Len(aMaster) > 1 )  )
			For nAux1 := 1 To Len( aCpoMaster )
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nAux1][1] ) } ) ) > 0;
						.And. ValType(aCpoMaster[nAux1][2]) <> "U"
					If !( lAux := oModel:SetValue( cMaster , aCpoMaster[nAux1][1],aCpoMaster[nAux1][2] ) )
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next
		EndIf

    Next nCount 

EndIf 

If lRet .And. lGrid

    For nCount := 1 To Len(aItens)

        aCpoDetail  := aClone( aItens[nCount,1] )
        cDetail     := aItens[nCount,2]
        cAliasAux   := aItens[nCount,3]

        dbSelectArea( cAliasAux )
	    dbSetOrder( 1 )

        oAux        := oModel:GetModel( cDetail  )
        
        oStruct := oAux:GetStruct()
        aAux 	:= oStruct:GetFields()
        nErro   := 0
		nLinGrid:= 0

		//-- Define se alinha do GRID será pesquisada
		If lPesqLine := (Len(aItens[nCount]) == 4 .And. aItens[nCount,4])
			aChvUnq := TmsChvUnq(oAux,Aclone(aAux))
		EndIf

        For nAux1 := 1 To Len( aCpoDetail )

			lFindLine := .F.
			If lPesqLine
				aPesqLine := {}
				For nCntFor1 := 1 To Len(aChvUnq)
					If (nPosCpo := aScan( aCpoDetail[nAux1] ,{|x| AllTrim(x[1]) == AllTrim( aChvUnq[nCntFor1])})) > 0
						Aadd( aPesqLine, { aChvUnq[nCntFor1], aCpoDetail[nAux1,nPosCpo,2] } )
					Else
						lPesqLine := .F.
						Exit
					EndIf
				Next nCntFor1

				If lPesqLine
					If oAux:SeekLine(aPesqLine)
						nLinAlt := oAux:GetLine()
						oAux:GoLine(nLinAlt)
						lFindLine := .T.
					EndIf
				EndIf
			EndIf

			If !lFindLine
	            If nOpc == 4
					nLinGrid:= oAux:Length()
					oAux:GoLine(nLinGrid)
					If !oAux:IsEmpty()
	                	oAux:AddLine()
					EndIf
	            ElseIf  nOpc == 3  .And. nAux1 > 1
	                If ( nErro := oAux:AddLine(.T.) ) <> nAux1                    
	                    lRet := .F.
	                    Exit
	                EndIf
	            EndIf
			EndIf

            For nAux2 := 1 To Len( aCpoDetail[nAux1] )
               
                If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetail[nAux1][nAux2][1] ) } ) ) > 0
                    If !( lAux := oModel:SetValue( cDetail, aCpoDetail[nAux1][nAux2][1], aCpoDetail[nAux1][nAux2][2] ) )
                        lRet := .F.
                        nErro := nAux1
                        Exit
                    EndIf
                EndIf
            Next

            If !lRet
                Exit
            EndIf

        Next

		If !lRet
            Exit
        EndIf

    Next nCount 
EndIf

If lRet
	If ( lRet := oModel:VldData() )
		oModel:CommitData()
	EndIf
EndIf

If !lRet .And. lExibErro

	aErro := oModel:GetErrorMessage()

	// A estrutura do vetor com erro é:
	// [1] identificador (ID) do formulário de origem
	// [2] identificador (ID) do campo de origem
	// [3] identificador (ID) do formulário de erro
	// [4] identificador (ID) do campo de erro
	// [5] identificador (ID) do erro
	// [6] mensagem do erro
	// [7] mensagem da solução
	// [8] Valor atribuído
	// [9] Valor anterior

	If !Empty( aErro[1] )
		Aadd( aMsgErr, { STR0268 + AllToChar( aErro[1] ), 00, '' } ) //-- "Id do formulário de origem:"
	EndIf
	If !Empty( aErro[2] )
		Aadd( aMsgErr, { STR0269 + AllToChar( aErro[2] ), 00, '' } )  //-- "Id do campo de origem: "
	EndIf
	If !Empty( aErro[3] )
		Aadd( aMsgErr, { STR0270 + AllToChar( aErro[3] ), 00, '' } )  //-- "Id do formulário de erro: "
	EndIf
	If !Empty( aErro[4] )
		Aadd( aMsgErr, { STR0271 + AllToChar( aErro[4] ), 00, '' } )  //-- "Id do campo de erro: "
	EndIf
	If !Empty( aErro[5] )
		Aadd( aMsgErr, { STR0272 + AllToChar( aErro[5] ), 00, '' } )  //-- "Id do erro: "
	EndIf
	If !Empty( aErro[6] )
		Aadd( aMsgErr, { STR0273 + AllToChar( aErro[6] ), 00, '' } )  //-- "Mensagem do erro: "
	EndIf
	If !Empty( aErro[7] )
		Aadd( aMsgErr, { STR0274 + AllToChar( aErro[7] ), 00, '' } )  //-- "Mensagem da solução: "
	EndIf
	If !Empty( aErro[8] )
		Aadd( aMsgErr, { STR0275 + AllToChar( aErro[8] ), 00, '' } )  //-- "Valor atribuído: "
	EndIf
	If !Empty( aErro[9] )
		Aadd( aMsgErr, { STR0276 + AllToChar( aErro[9] ), 00, '' } )  //-- "Valor anterior: "
	EndIf
	If nErro > 0
		Aadd( aMsgErr, { STR0277 + AllTrim( AllToChar( nErro ) ) } )  //-- "Erro no Item: "
	EndIf
	TMSMsgErr( aMsgErr, cMsgErr )
EndIf

// Desativamos o Model
oModel:DeActivate()
oModel:Destroy()

FwFreeObj(oModel)
FwFreeArray(aMsgErr)
FwFreeArray(aChvUnq)
FwFreeArray(aPesqLine)

RestArea( aArea )
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMCOMPPDG³  Autor ³ Jose Marcio	        ³ Data ³07.11.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existe composição para o veiculo, caso exista   ³±±
±±³			  obtem o valor do pedagio									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMCOMPPDG(aVeiculos,cLotNfc,nRet,cRotaVge)   		 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Veiculos da viagem                                  ³±±
±±³          ³ExpC2 - Valor do pedagio 	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Lógico						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMCOMPPDG(aVeiculos,cLotNfc,nRet,cRotaVge,aPrcPdgOP)

Local lRet			:= .T.
Local nA			:= 0
Local cDU2			:= ""
Local cCampo		:= ""
Local lTMCALPDG	 := ExistBlock('TMCALPDG')

Default aVeiculos 	:= {}
Default cLotNfc		:= ''
Default cRotaVge		:= ''
Default aPrcPdgOP    := {}

If !IsInCallStack("TMSA240")
	If IsInCallStack("TMSA190")
		cRotaVge := DTQ->DTQ_ROTA
	Else
		If Empty(cRotaVge) .And. !Empty(M->DTQ_ROTA)
			cRotaVge := M->DTQ_ROTA
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o Valor do Pedagio sobra a composição. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-- Posiciona no cadastro da Praca de Pedagio para pesquisar a composicao do veiculo
cCodComp :=	TMRETCOMPG(aVeiculos)
If  !Empty(cRotaVge)
	DU0->( DbSetOrder( 1 ) )
	DU2->( DbSetOrder( 1 ) )
	DYP->( DbSetOrder( 2 ) )

	For nA := 1 to Len(aVeiculos)
		//-- Posiciona no cadastro de veiculos
		If DA3->( MsSeek( xFilial('DA3') + aVeiculos[nA,1], .F. ) )
			//-- Posiciona no Cadastro de Tipos de Veiculos
			If DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
				//-- Posiciona no cadastro de Rota X Rodovia
				If DU2->(MsSeek(cDU2 := xFilial("DU2") + cRotaVge ))
					While DU2->(!Eof()) .And. DU2->(DU2_FILIAL+DU2_ROTA) == cDU2
						// -- Posiciona no cadastro de pracas de pedagio
						If DU0->( MsSeek(xFilial("DU0") + DU2->(DU2_CODROD+DU2_SEQPDG) ))
							//-- Se não houver composição posiciona no cadastro da Praca de Pedagio para pesquisar o tipo do veiculo
							If Empty(cCodComp) .And. DYP->(MsSeek(xFilial("DYP") + DU0->(DU0_CODROD+DU0_SEQPDG)+DUT->DUT_TIPVEI ))
								If lTMCALPDG
									cCampo += Execblock("TMCALPDG",.F.,.F.,{cLotNfc})
								EndIf
								If !Empty(cCampo)
									nRet += DYP->&cCampo
								Else
									nRet += DYP->DYP_VALOR // Obtem o valor referente a composição
									aAdd(aPrcPdgOP, {AllTrim(DU0->DU0_IOFPDG), DYP->DYP_VALOR})
								EndIf
							Else
								If !Empty(cCodComp)
									If DYP->(MsSeek(xFilial("DYP") + DU0->(DU0_CODROD+DU0_SEQPDG)+cCodComp ))
										If lTMCALPDG
											cCampo += Execblock("TMCALPDG",.F.,.F.,{cLotNfc})
										EndIf
										If !Empty(cCampo)
											nRet := DYP->&cCampo
										Else
											nRet := DYP->DYP_VALOR // Obtem o valor referente a composição
										EndIf
									Else
										lRet := .F.
										Exit
			                     EndIf
								Else
									lRet := .F.
									Exit
		                     EndIf
							EndIf
						Else
							lRet := .F.
							Exit
						EndIf
						DU2->( DbSkip() )
					EndDo
					If !lRet
						Exit
					EndIf
				Else
					lRet := .F.
					Exit
				EndIf
			Else
				lRet := .F.
				Exit
			EndIf
		Else
			lRet := .F.
			Exit
		EndIf
	Next nA
Else
	lRet := .F.
EndIf

If nRet == 0
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMRETCOMPG³ Autor ³Fabio Marchiori Sampaio³ Data ³26.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existe composição para o veiculo, caso exista   ³±±
±±³			  obtem o tipo da composição								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMRETCOMPG()						 	            		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - 					                                  ³±±
±±³          ³ExpC2 -               	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Caracter						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMRETCOMPG(aVeiculos)

Local cRet			:= ""
Local cCodVei		:= ""
Local cCodRB1		:= ""
Local cCodRB2		:= ""
Local cCodRB3		:= ""
Local cQuery		:= ""
Local cAliasComp	:= GetNextAlias()
Local lTercRbq	:= DTR->(ColumnPos("DTR_CODRB3")) > 0
Local nX			:= 0

Default aVeiculos:= {}

If Len(aVeiculos) > 0

	For nX := 1 to Len(aVeiculos)
		If !Empty(Alltrim(aVeiculos[nX,1]))
			//-- Posiciona no cadastro de veiculos
			DA3->( MsSeek( xFilial('DA3') + aVeiculos[nX,1], .F. ) )
			//-- Posiciona no Cadastro de Tipos de Veiculos
			If DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
				If DUT->DUT_CATVEI ==  '3'  //Carreta
					If Empty(cCodRB1)
						cCodRB1:= DA3->DA3_TIPVEI
					ElseIf Empty(cCodRB2)
						cCodRB2:= DA3->DA3_TIPVEI
					ElseIf lTercRbq .And. Empty(cCodRB3)
	        			cCodRB3:= DA3->DA3_TIPVEI
					EndIf
				Else
					cCodVei:= DA3->DA3_TIPVEI
				EndIf

			EndIf
		EndIf
	Next nX
Else
	If IsInCallStack('TMSA240Mnt') .Or. IsInCallStack("TMSAF76")
		If Valtype(GDFieldGet("DTR_CODVEI",n,.T.))  == 'C'
	        cCodVei:= Posicione("DA3",1,xFilial("DA3") + GDFieldGet("DTR_CODVEI",n,.T.) ,"DA3_TIPVEI")
		EndIf
		If  Valtype(GDFieldGet("DTR_CODRB1",n,.T.))  == 'C'
	        cCodRB1:= Posicione("DA3",1,xFilial("DA3") + GDFieldGet("DTR_CODRB1",n,.T.) ,"DA3_TIPVEI")
		EndIf
		If  Valtype(GDFieldGet("DTR_CODRB2",n,.T.))  == 'C'
	        cCodRB2:= Posicione("DA3",1,xFilial("DA3") + GDFieldGet("DTR_CODRB2",n,.T.) ,"DA3_TIPVEI")
		EndIf
		If lTercRbq .And. Valtype(GDFieldGet("DTR_CODRB3",n,.T.))  == 'C'
	        cCodRB3:= Posicione("DA3",1,xFilial("DA3") + GDFieldGet("DTR_CODRB3",n,.T.) ,"DA3_TIPVEI")
		EndIf
	EndIf
EndIf

cQuery := " SELECT DYO.DYO_CODCPO "
cQuery += " FROM "+ RetSqlName("DYO") + " DYO "
cQuery += " WHERE  DYO.DYO_FILIAL = '" + xFilial("DYO") + "' "
cQuery += "        AND DYO.DYO_ITEM = '01' "
cQuery += "              AND DYO.DYO_TIPVEI = '"+cCodVei+"'"
If !Empty(cCodRB1)
	cQuery += "        AND EXISTS (SELECT DYO1.DYO_CODCPO "
	cQuery += "                    FROM "+ RetSqlName("DYO") + " DYO1 "
	cQuery += "                    WHERE  DYO1.DYO_FILIAL = '" + xFilial("DYO") + "' "
	cQuery += "                           AND DYO1.DYO_ITEM = '"+StrZero(2,Len(DYO->DYO_ITEM))+"' "
	cQuery += "                           AND DYO1.DYO_TIPVEI = '"+cCodRB1+"' "
	cQuery += "                           AND DYO1.DYO_CODCPO = DYO.DYO_CODCPO "
	cQuery += "                           AND DYO1.D_E_L_E_T_ = ' ') "
	If !Empty(cCodRB2)
		cQuery += "        AND EXISTS (SELECT DYO2.DYO_CODCPO "
       cQuery += "                    FROM "+ RetSqlName("DYO") + " DYO2 "
       cQuery += "                    WHERE  DYO2.DYO_FILIAL = '" + xFilial("DYO") + "' "
       cQuery += "                           AND DYO2.DYO_ITEM = '"+StrZero(3,Len(DYO->DYO_ITEM))+"' "
       cQuery += "                           AND DYO2.DYO_TIPVEI = '"+cCodRB2+"' "
       cQuery += "                           AND DYO2.DYO_CODCPO = DYO.DYO_CODCPO "
       cQuery += "                           AND DYO2.D_E_L_E_T_ = ' ') "
	ElseIf !Empty(cCodRB3) .And. lTercRbq
		cQuery += "        AND EXISTS (SELECT DYO3.DYO_CODCPO "
		cQuery += "                    FROM "+ RetSqlName("DYO") + " DYO3 "
		cQuery += "                    WHERE  DYO3.DYO_FILIAL = '" + xFilial("DYO") + "' "
		cQuery += "                           AND DYO3.DYO_ITEM = '"+StrZero(4,Len(DYO->DYO_ITEM))+"' "
		cQuery += "                           AND DYO3.DYO_TIPVEI = '"+cCodRB3+"' "
       cQuery += "                           AND DYO3.DYO_CODCPO = DYO.DYO_CODCPO "
       cQuery += "                           AND DYO3.D_E_L_E_T_ = ' ') "
	Else
		cQuery += "        AND NOT EXISTS (SELECT DYO2.DYO_CODCPO "
       cQuery += "                    FROM "+ RetSqlName("DYO") + " DYO2 "
       cQuery += "                    WHERE  DYO2.DYO_FILIAL = '" + xFilial("DYO") + "' "
       cQuery += "                           AND DYO2.DYO_ITEM = '"+StrZero(3,Len(DYO->DYO_ITEM))+"' "
       cQuery += "                           AND DYO2.DYO_CODCPO = DYO.DYO_CODCPO "
       cQuery += "                           AND DYO2.D_E_L_E_T_ = ' ') "
	EndIf
Else
    cQuery += "        AND NOT  EXISTS (SELECT DYO1.DYO_CODCPO "
    cQuery += "                    FROM  "+ RetSqlName("DYO") + " DYO1 "
    cQuery += "                    WHERE  DYO1.DYO_FILIAL = '" + xFilial("DYO") + "' "
    cQuery += "                           AND DYO1.DYO_ITEM = '"+StrZero(2,Len(DYO->DYO_ITEM))+"' "
    cQuery += "                           AND DYO1.DYO_CODCPO = DYO.DYO_CODCPO "
    cQuery += "                           AND DYO1.D_E_L_E_T_ = ' ') "
EndIf
cQuery += "        AND DYO.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery),cAliasComp, .F., .T.)

If (cAliasComp)->(!Eof())
	cRet := (cAliasComp)->DYO_CODCPO
EndIf

Return(allTrim(cRet))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsSobServ ³ Autor ³ Valdemar Roberto  ³ Data ³ 05.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para subir servico (DUX ou DDC/DDA)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsSobServ(cEpx01,lExp01,lExp02,cExp02,cExp03,cExp04)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ cExpC1 = Campo a ser pesquisado                            ³±±
±±³          ³ lExp01 = Indica se usa item de contrato                    ³±±
±±³          ³ lExp02 = Indica se sobe para o nivel superior              ³±±
±±³          ³ cExp02 = Numero do contrato                                ³±±
±±³          ³ cExp03 = Codigo da negociacao                              ³±±
±±³          ³ cExp04 = Servico de negociacao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsSobServ(cCampo,lTMSItCt,lSobSrv,cNumCtc,cCodNeg,cServic,cNaoUtil,nAdiDoc,lSobDUX)

Local aAreas 	 := {DUX->(GetArea()),DDC->(GetArea()),DDA->(GetArea()),GetArea()}
Local xRet
Local cAuxCpo	 := ""

Default cCampo   := ""
Default lTMSItCt := .F.
Default lSobSrv  := .F.
Default cNumCtc  := ""
Default cCodNeg  := ""
Default cServic  := ""
Default cNaoUtil := "0"   //No caso do Rateio, o nao utiliza é 1.
Default nAdiDoc  := 0
Default lSobDUX  := .T.

//-- A partir da versao 12.1.17 não existirá mais a tabela DUX
lSobDUX := .F.

If ExistCpo("SX3","DDC_" + cCampo ,2)
	cAuxCpo	:= "DDC_" + cCampo
ElseIf ExistCpo("SX3","DDA_" + cCampo,2)
	cAuxCpo	:= "DDA_" + cCampo
Else
	cCampo	:= ""
EndIf

If !Empty(cCampo) //-- Existe um campo a considerar
	If GetSX3Cache(cAuxCpo,"X3_TIPO") == "N"
		xRet := 0
	Else
		xRet := Space( GetSX3Cache(cAuxCpo,"X3_TAMANHO") )
	EndIf

	DDA->(DbSetOrder(2))
	If DDA->(DbSeek(xFilial("DDA") + cNumCtc + cCodNeg + cServic))
		nAdiDoc:= DDA->DDA_ADIDOC

		If lSobSrv .And. (&("DDA->DDA_" + cCampo) == cNaoUtil  .OR. Empty(&("DDA->DDA_" + cCampo)))
			DDC->(DbSetOrder(2))
			If DDC->(DbSeek(xFilial("DDC") + cNumCtc + cCodNeg))
				xRet   := &("DDC->DDC_" + cCampo)
				If nAdiDoc == 0
					nAdiDoc:= DDC->DDC_ADIDOC
				EndIf
			EndIf
		Else
			xRet   := &("DDA->DDA_" + cCampo)

			If nAdiDoc == 0
				DDC->(DbSetOrder(2))
				If DDC->(DbSeek(xFilial("DDC") + cNumCtc + cCodNeg))
					nAdiDoc:= DDC->DDC_ADIDOC
				EndIf
			EndIf
		EndIf
	EndIf
Else
	xRet := ""
EndIf

AEval(aAreas,{|x,y| RestArea(x)})

Return xRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsPrzEnt ³ Autor ³ Leandro Paulino   ³ Data ³ 23.05.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o prazo de entrega do documento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsPrzEnt(nEpx01,lExp01,lExp02,cExp02,cExp03,cExp04)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ cExpC1 = Campo a ser pesquisado                            ³±±
±±³          ³ lExp01 = Indica se usa item de contrato                    ³±±
±±³          ³ lExp02 = Indica se sobe para o nivel superior              ³±±
±±³          ³ cExp02 = Numero do contrato                                ³±±
±±³          ³ cExp03 = Codigo da negociacao                              ³±±
±±³          ³ cExp04 = Servico de negociacao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsPrzEnt(nRet,aRet,cCliRem, cLojRem, cCliDes, cLojDes,cSqEDes,cCdrDes, cCdrOri, cCliDev, cLojDev, cTipTra, cCdrCal)

Local aCliPrz := {}
Local lTm200Prz  := ExistBlock('Tm200PRZ')
Local dDtTM200   := CToD('  /  /  ')
Local dDataEnt   := dDataBase
Local aTmpEnt	   := {}
Local dNovaData  := CToD('  /  /  ')
Local cHoraBase  := StrTran(Left(Time(),5),':','')
Local cCdrPrz    := ''
Local cRet       := ''
Local lTm200DAT  := ExistBlock('Tm200DAT')

Default nRet     := 1 //1=Data;2=Hora
Default aRet     := {}//Array com o retorno da Data e Hora da previsão de entrega, utilizando quando a função não for chamada pelo Gatilho.
Default cCliRem  := IIf(Type('M->DTC_CLIREM')== 'C',M->DTC_CLIREM,'')
Default cLojRem  := IIf(Type('M->DTC_LOJREM')== 'C',M->DTC_LOJREM,'')
Default cCliDes  := IIf(Type('M->DTC_CLIDES')== 'C',M->DTC_CLIDES,'')
Default cLojDes  := IIf(Type('M->DTC_LOJDES')== 'C',M->DTC_LOJDES,'')
Default cSqeDes  := IIf(Type('M->DTC_SQEDES')== 'C',M->DTC_SQEDES,'')
Default cCdrDes  := IIf(Type('M->DTC_CDRDES')== 'C',M->DTC_CDRDES,'')
Default cCdrOri  := IIf(Type('M->DTC_CDRORI')== 'C',M->DTC_CDRORI,'')
Default cCliDev  := IIf(Type('M->DTC_CLIDEV')== 'C',M->DTC_CLIDEV,'')
Default cLojDev  := IIf(Type('M->DTC_LOJDEV')== 'C',M->DTC_LOJDEV,'')
Default cTipTra  := IIf(Type('M->DTC_TIPTRA')== 'C',M->DTC_TIPTRA,'')
Default cCdrCal  := IIf(Type('M->DTC_CDRCAL')== 'C',M->DTC_CDRCAL,'')

If !Empty(cTipTra) .And. !Empty(cCdrOri)

	//-- Se informado Seq.Endereco para destinatario retornar codigo regiao para calculo do prazo de entrega
	cCdrPrz := cCdrDes
	If !Empty(cSqEDes)
		DUL->(dbSetOrder(2))
		If DUL->(MsSeek(xFilial("DUL") + cCliDes + cLojDes + cSqEDes) .And. !Empty(DUL_CDRDES))
			cCdrPrz := DUL->DUL_CDRDES
		EndIf
	EndIf
	//-- Se alterada regiao de calculo deve usar esta para calculo do prazo de entrega.
	If	cCdrDes <> cCdrCal
		cCdrPrz := cCdrCal
	EndIf


	//-- Obtem o cliente para calculo do prazo de entrega
	aCliPrz := TmsCliCalc( cCliRem, cLojRem, cCliDes, cLojDes, .T. )
	//-- Calcula tempo de entrega
	If	lTm200Prz
		dDtTM200 := ExecBlock('TM200PRZ',.F.,.F.,{cCdrOri,cCdrPrz,cTipTra,;
					Iif(Empty(aCliPrz),cCliDev,aCliPrz[1]),;
					Iif(Empty(aCliPrz),cLojDev,aCliPrz[2]),dDataEnt,cHoraBase,cCdrCal})
		If ValType(dDtTM200) == "D"
			dDataEnt := dDtTM200
		EndIf
	Else
		//-- Calcula tempo de entrega
		If	Empty(aCliPrz)
			aTmpEnt := TmsTmpEntr( cTipTra, cCdrOri, cCdrPrz, cCliDev, cLojDev )
		Else
			aTmpEnt := TmsTmpEntr( cTipTra, cCdrOri, cCdrPrz, aCliPrz[1], aCliPrz[2] )
		EndIf

		If	!Empty( aTmpEnt )
			//-- Calcula a data de entrega
			SomaDiaHor( @dDataEnt, @cHoraBase, TmsHrToInt( aTmpEnt[ 2 ] ) )
			dNovaData := TmsHrFer(dDataEnt,cCdrPrz)
			If	dDataEnt <> dNovaData
				dDataEnt := dNovaData
			EndIf
			//Este ponto de entrada 'TM200DAT' foi uma solicitação
			//pois o modelo atual quando se faz um cálculo no SAB
			//e o sistema está configurado para aceitar apenas dias
			//úteis, a contagem é feita como se o cálculo fosse de
			//feito na SEG.
			If	lTm200DAT
				dDtTM200 := ExecBlock('TM200DAT',.F.,.F.,{dDataEnt,cCdrPrz,cHoraBase,aTmpEnt,cTipTra,cCdrOri,;
										(Iif(Empty(aCliPrz),cCliDev,aCliPrz[1])),;
										(Iif(Empty(aCliPrz),cLojDev,aCliPrz[2])),cCdrCal})
				If ValType(dDtTM200) == "D"
					dDataEnt := dDtTM200
				EndIf
			EndIf
		EndIf
	EndIf

	If nRet == 1
		cRet := dDataEnt
	Else
		cRet := cHoraBase
	EndIf

	AADD(aRet,dDataEnt)
	AADD(aRet,cHOraBase)
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsPrzCond ³ Autor ³ Leandro Paulino   ³ Data ³ 23.05.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Condicao para execucao do gatilho chamado pela funcao      ³±±
±±				 TmsPrzEnt()                                                 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsPrzCond()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsPrzCond()

Local lRet := .T.

If Empty(M->DTC_TIPTRA) .Or. Empty(M->DTC_CDRORI) .Or. Empty(M->DTC_CDRCAL)
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} TMSFUNAClr
//TODO Função que zera cache de memória das varíaveis estáticas
@author caio.y
@since 17/04/2018
@version 1.0
@return ${return}, ${return_description}
@param xNomeVar, , Nome da Variavel
@param lKill, logical, Indica se será atribuido Nil
@type function
/*/
Function TMSFUNAClr( cNomeVar , lKill )

Default cNomeVar	:= ""
Default lKill		:= .F.

If ValType(&cNomeVar) == "A"

	&cNomeVar	:=	aSize(&cNomeVar,0)

	If lKill
		&cNomeVar	:= NIl
	Else
		&cNomeVar	:= {}
	EndIf

EndIf

Return


/*/{Protheus.doc} TmsChekSX1
//TODO Função que verifica se existe o pergunte existe 
@author leandro Paulino
@since 04/03/2020
@type function
/*/
Function TmsChekSX1(cPerg)

    Local oObj := FWSX1Util():New()
    Local lRet := .F.

	Default cPerg := ''

    oObj:AddGroup(cPerg)
    oObj:SearchGroup()
    lRet := Len(oObj:GetGroup(cPerg)[2]) > 0

    FreeObj(oObj)
    
Return lRet

/*{Protheus.doc} TmsChvUnq()
Recupera os campos da Unique Line do Grid
@type Function
@author Valdemar Roberto Mognon
@since 08/10/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TmsChvUnq(oModel,aStruct)
Local aRet     := {}
Local aVetWrk  := {}
Local nCntFor1 := 0

Default oModel  := Nil
Default aStruct := {}

aVetWrk := oModel:aUnique

For nCntFor1 := 1 To Len(aVetWrk)
	Aadd(aRet,aStruct[aVetWrk[nCntFor1],3])
Next nCntFor1

FwFreeArray(aVetWrk)

Return Aclone(aRet)

/*{Protheus.doc} TmsTipoRot()
Consulta específica para os tipos de rotina
@type Function
@author Valdemar Roberto Mognon
@since 02/02/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TmsTipoRot(cCampo)
Local lRet     := .T.

Default cCampo := ReadVar()

lRet := TMSValField(cCampo,,,.T.,,.F.)

Return lRet

/*{Protheus.doc} TmsAutViag()
Consulta específica para os tipos de rotina
@type Function
@author Valdemar Roberto Mognon
@since 04/02/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TmsAutViag(cFilOri,cViagem,cCodAut,cRotina)
Local lRet     := .F.
Local lVgeMod3 := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local aArea    := GetArea()
Local aAreaDMB := {}

Default cCodAut := ""
Default cRotina := ""

If lVgeMod3 .And. !Empty(cFilOri) .And. !Empty(cViagem) .And. !Empty(cCodAut) .And. !Empty(cRotina) .And. AliasInDic("DMB")
	aAreaDMB := DMB->(GetArea())
	DMB->(DbSetOrder(2))
	If DMB->(DbSeek(xFilial("DMA") + cFilOri + cViagem + cCodAut + cRotina))
		lRet := (DMB->DMB_ROTAUT == StrZero(1,Len(DMB->DMB_ROTAUT)))
	EndIf
	RestArea(aAreaDMB)
EndIf

RestArea(aArea)

Return lRet


/*{Protheus.doc} TmsSerie()
Retorna a Serie de acordo com o cadastro da tabela
@type Function
@author Felipe Barbiere
@since 04/03/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TmsSerie(cSerie, cContr, cCodNeg, cServic)

Local lMultSerie := DDA->(FieldPos('DDA_SERIE')) > 0
Local cCampo	 := "SERIE"

Default cSerie 	:= ""
Default cContr 	:= ""
Default	cCodNeg := ""
Default cServic	:= ""

If lMultSerie
	cSerieServ := TmsSobServ(cCampo, .T., .T., cContr, cCodNeg, cServic)
	If !Empty(cSerieServ)
		cSerie := cSerieServ
	EndIf
EndIf

Return cSerie

/*{Protheus.doc} MntFilRot
Função que faz o filtro das rotas selecionadas/preenchidas no campo DTQ_ROTA
@author João Venturini
@since 17/11/2021
*/
Function MntFilRot(cSerTMS,cTipTra,cTransfDe,cTransfAte,cEntrDe,cEntrAte,lallRot,lVgeMod3)

Local cFiltraDA8 := ""
Local aAreas     := {DA8->(GetArea()),GetArea()}

Default cSerTMS := ""
Default cTipTra := ""
Default cTransfDe := ""
Default cTransfAte := Replicate("Z",Len(DA8->DA8_COD))
Default cEntrDe := ""
Default cEntrAte := Replicate("Z",Len(DA8->DA8_COD))
Default lallRot := .F.
Default lVgeMod3 := .T.

DA8->(dbSetOrder(1))
cFiltraDA8 := "DA8_FILIAL=='"+xFilial("DA8")+"'"
If !lAllRot
	cFiltraDA8 += ".And.DA8_CDRORI=='"+Padr(GetMv("MV_CDRORI",,""),Len(DA8->DA8_CDRORI))+"'"
EndIf
If !Empty(cSerTms) .And. !Empty(cTipTra)
	cFiltraDA8 += ".And.DA8_SERTMS=='"+cSerTms+"'.And.DA8_TIPTRA=='"+cTipTra+"'"
EndIf
If !Empty(cSerTms) .And. cSerTms == "2" 
	If !lVgeMod3
		If !Empty(cTransfAte)
			cFiltraDA8 += ".And.DA8_COD>='"+cTransfDe+"'.And.DA8_COD<='"+cTransfAte+"'"
		EndIf
	EndIf	
ElseIf !Empty(cEntrDe) .And. !Empty(cEntrAte) .And. cSerTms != "2"
	cFiltraDA8 += ".And.DA8_COD>='"+cEntrDe+"'.And.DA8_COD<='"+cEntrAte+"'"
EndIf

If lTMAFilRot .AND. lVgeMod3
 	cFiltraDA8 := ExecBlock( 'TMAFILROT', .F., .F., { cSerTms, cTipTra, cFiltraDA8 } )
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cFiltraDA8
