#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MDTM002.CH"

//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//  _______           _______  _       _________ _______             _______  _______  _______  __    _______  ------
// (  ____ \|\     /|(  ____ \( (    /|\__   __/(  ___  )           (  ____ \/ ___   )/ ___   )/  \  (  __   ) ------
// | (    \/| )   ( || (    \/|  \  ( |   ) (   | (   ) |           | (    \/\/   )  |\/   )  |\/) ) | (  )  | ------
// | (__    | |   | || (__    |   \ | |   | |   | |   | |   _____   | (_____     /   )    /   )  | | | | /   | ------
// |  __)   ( (   ) )|  __)   | (\ \) |   | |   | |   | |  (_____)  (_____  )  _/   /   _/   /   | | | (/ /) | ------
// | (       \ \_/ / | (      | | \   |   | |   | |   | |                 ) | /   _/   /   _/    | | |   / | | ------
// | (____/\  \   /  | (____/\| )  \  |   | |   | (___) |           /\____) |(   (__/\(   (__/\__) (_|  (__) | ------
// (_______/   \_/   (_______/|/    )_)   )_(   (_______)           \_______)\_______/\_______/\____/(_______) ------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDTM002
Rotina de Envio de Eventos - Comunica��o de Acidente de Trabalho (S-2210)
Realiza a composi��o do Xml a ser enviado ao Governo

@return cRet, Caracter, Retorna o Xml gerado pela CAT

@sample MDTM002( 3, .T., {}, oModel )

@param nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param lIncons, Boolean, Indica se � avalia��o de inconsist�ncias das informa��es de envio
@param aIncEnv, Array, Array que recebe as inconsist�ncias, se houver, das informa��es a serem enviadas
@param oModelTNC, Objeto, Indica o modelo utilizado para fazer a manipula��o dos registros caso seja chamado pelo MDTA640A
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE
@param cChvNov, Caracter, Chave nova do registro a ser utilizada para verificar se deve buscar o TAFKEY
@param cTAFKey, Caracter, Chave a ser retornado no caso de altera��o da data, hora ou tipo do acidente

@author Luis Fellipy Bett
@since	10/07/2018
/*/
//-------------------------------------------------------------------------------------------------------------------
Function MDTM002( nOper, lIncons, aIncEnv, oModelTNC, cChave, cChvNov, cTAFKey )

	Local aArea		:= GetArea()
	Local aAreaTNC	:= TNC->( GetArea() )
	Local cRet		:= ""
	Local cSeekAci	:= ""
	Local nCont		:= 0
	Local nLenGrid	:= 0
	Local oCausa
	Local oParte
	Local aDadFun  := {} //Busca as informa��es do funcion�rio

	//Vari�veis de chamadas
	Local lXml := IsInCallStack( "MDTGeraXml" ) //Verifica se � gera��o de Xml

	//Vari�veis auxiliares para busca das informa��es a serem enviadas
	Private cNumMat				:= "" //Matr�cula do Funcion�rio (RA_MAT)
	Private cNomeFun			:= "" //Nome do Funcion�rio (RA_NOME)
	Private dDtAdm				:= SToD( "" ) //Data de Admiss�o do Funcion�rio (RA_ADMISSA)
	Private cCodMedico			:= "" //C�digo do m�dico/dentista que emitiu o Atestado (TMT_CODUSU ou TNY_EMITEN)
	Private cCodUF				:= "" //Vari�vel auxiliar para busca do c�digo da UF, caso envio via Middleware
	Private lAtesAcid			:= .F. //Vari�vel de verifica��o de valida��o do atendimento pelo acidente
	Private aInfAten			:= {} //Busca as informa��es do atendimento m�dico

	//Vari�veis das informa��es a serem envidas
	Private cTpInsc				:= IIf( SM0->M0_TPINSC == 2, "1", IIf( SM0->M0_TPINSC == 3, "2", "" ) ) //Tipo de Inscri��o da Empresa
	Private cCpfTrab			:= "" //CPF do Funcion�rio (RA_CIC)
	Private cMatricula			:= "" //Matr�cula do Funcion�rio a ser considerada no envio (RA_CODUNIC)
	Private cCodCateg			:= "" //Categoria do Funcion�rio (RA_CATEFD)
	Private dDtAcid				:= SToD( "" ) //Data do Acidente (TNC_DTACID)
	Private cTpAcid				:= "" //Tipo do Acidente (TNC_INDACI)
	Private cHrAcid				:= "" //Hora do Acidente (TNC_HRACID)
	Private cHrsTrabAntesAcid	:= "" //Horas trabalhadas anteriormente ao acidente ()
	Private cTpCat				:= "" //Tipo de CAT (TNC_TIPCAT)
	Private cIndCatObito		:= "" //Indica��o de �bito (TNC_MORTE)
	Private dDtObito			:= SToD( "" ) //Data do �bito (TNC_DTOBIT)
	Private cIndComunPolicia	:= "" //Indica��o de Comunica��o � Autoridade Policial (TNC_POLICI)
	Private cCodSitGeradora		:= "" //C�digo do Situa��o Geradora do Acidente (TNG_ESOC)
	Private cObsCat				:= "" //Observa��o da CAT (TNC_DETALH)
	Private cTpLocal			:= "" //Tipo do Local do Acidente (TNC_INDLOC)
	Private cDscLocal			:= "" //Descri��o do Local do Acidente (TNC_LOCAL)
	Private cTpLograd			:= "" //Tipo de Logradouro do Acidente (TNC_TPLOGR)
	Private cDscLograd			:= "" //Descri��o do Logradouro do Acidente (TNC_DESLOG)
	Private cNrLograd			:= "" //N�mero do Logradouro do Acidente (TNC_NUMLOG)
	Private cComplemento		:= "" //Complemento do Logradouro do Acidente (TNC_COMPL)
	Private cBairro				:= "" //Bairro do Local do Acidente (TNC_BAIRRO)
	Private cCEP				:= "" //CEP do Local do Acidente (TNC_CEP)
	Private cCodMunic			:= "" //C�digo do Munic�pio do Local do Acidente (Se for Middleware: C�digo da UF + TNC_CODCID, sen�o: TNC_CODCID )
	Private cUFAci				:= "" //UF do Local do Acidente (TNC_ESTACI)
	Private cCodPai				:= "" //Pa�s do Local do Acidente (C08_PAISSX)
	Private cCodPostal			:= "" //C�digo de Endere�amento Postal do Acidente (TNC_CODPOS)
	Private cTpInscAci			:= "" //Tipo de Inscri��o do Local do Acidente (TNC_TPINS)
	Private cNrInscAci			:= "" //N�mero de Inscri��o do Local do Acidente (TNC_CGCPRE)
	Private aParte				:= {} //Parte Atingida e Lateralidade do Funcion�rio que sofreu o Acidente (TOI_ESOC e TYF_LATERA)
	Private aCausa				:= {} //Agente Causador do Acidente (TNH_ESOC)
	Private dDtAtendimento 		:= SToD( "" ) //Data do Atendimento do Funcion�rio que sofreu o Acidente (TNC_DTATEN, TMT_DTATEN ou TNY_DTCONS)
	Private cHrAtendimento 		:= "" //Hora de Atendimento do Funcion�rio que sofreu o Acidente (TNC_HRATEN, TMT_HRATEN ou TNY_HRCONS)
	Private cIndInternacao		:= "" //Indicativo de Interna��o do Funcion�rio que sofreu o Acidente (TNC_INTERN)
	Private cDurTrat 			:= "" //Dura��o do Tratamento do Funcion�rio que sofreu o Acidente (TNC_QTAFAS, TMT_QTAFAS ou TNY_QTDTRA)
	Private cIndAfast 			:= "" //Indicativo de Afastamento (TNC_AFASTA, TMT_QTAFAS ou TNY_CODAFA)
	Private cDscLesao			:= "" //C�digo da Descri��o da Natureza da Les�o (TOJ_ESOC)
	Private cDscCompLesao 		:= "" //Descri��o Complementar da Les�o (TNC_DESLES)
	Private cDiagProvavel 		:= "" //Diagn�stico Prov�vel do Atendimento (TMT_DIAGNO)
	Private cCodCID				:= "" //CID do Acidente (TNC_CID, TMT_CID ou TNY_CID)
	Private cObservacao			:= "" //Observa��o do Atendimento (TMT_OUTROS)
	Private cNmEmit 			:= "" //Nome do m�dico/dentista que emitiu o Atestado (TMK_NOMUSU ou TNP_NOME)
	Private cIdeOC 				:= "" //�rg�o de Classe do Emitente do Atestado (TMK_ENTCLA ou TNP_ENTCLA)
	Private cNrOC 				:= "" //N�mero de Inscri��o no �rg�o de Classe (TMK_NUMENT ou TNP_NUMENT)
	Private cUfOC 				:= "" //UF do �rg�o de Classe (TMK_UF ou TNP_UF)
	Private cNrRecCatOrig		:= "" //N�mero do Recibo da �ltima CAT, quando a CAT atual ser de reabertura ou de �bito (Se Middleware)

	Default lIncons	  := .F.
	Default nOper	  := 3
	Default oModelTNC := Nil
	Default cChvNov	  := ""
	Default cTAFKey	  := ""

	If lXml
		cSeekAci := TNC->TNC_FILIAL + TNC->TNC_ACIDEN
	ElseIf lDiagnostico
		cSeekAci := xFilial( "TNC" ) + M->TMT_ACIDEN
	ElseIf lAtestado
		cSeekAci := xFilial( "TNC" ) + M->TNY_ACIDEN
	EndIf

	If lDiagnostico .Or. lAtestado .Or. lXml //Alimenta as vari�veis de mem�ria para utiliza��o
		dbSelectArea( "TNC" )
		dbSetOrder( 1 )
		dbSeek( cSeekAci )
		RegToMemory( "TNC", .F., , .F. ) //Carrega os valores do Acidente na mem�ria
	EndIf

	aDadFun := MDTDadFun( M->TNC_NUMFIC )

	//Verifica se valida as informa��es do atendimento atrav�s do acidente
	lAtesAcid := !Empty( M->TNC_DTATEN ) .And. !Empty( M->TNC_HRATEN )

	//Vari�veis auxiliares para busca de informa��es a serem enviadas
	cNumMat	 := aDadFun[1] //Matr�cula do Funcion�rio
	cNomeFun := aDadFun[2] //Nome do Funcion�rio
	dDtAdm	 := aDadFun[6] //Data de Admiss�o do Funcion�rio

	//Busca da informa��o a ser enviada na tag <cpfTrab>
	cCpfTrab := aDadFun[3] //CPF do Funcion�rio

	//Busca da informa��o a ser enviada na tag <matricula>
	cMatricula := aDadFun[4] //C�digo �nico do Funcion�rio

	//Busca da informa��o a ser enviada na tag <matricula>
	cCodCateg := aDadFun[5] //Categoria do Funcion�rio

	//Verifica se existe CAT Origem e busca as informa��es das tags <dtAcid> e <hrAcid>
	MDTCATOrig( M->TNC_TIPCAT, M->TNC_DTACID, M->TNC_HRACID )

	//Busca da informa��o a ser enviada na tag <tpAcid>
	cTpAcid	:= M->TNC_INDACI

	//------- Tipo de Acidente de Trabalho -------
	//	1- Acidente Tipico			1- T�pico
	//	2- Acidente de Trajeto		3- Trajeto
	//	3- Doenca do Trabalho		2- Doen�a
	//-----------------------------------
	Do Case
		Case cTpAcid == "2" ; cTpAcid := "3"
		Case cTpAcid == "3" ; cTpAcid := "2"
	End Case

	//Busca da informa��o a ser enviada na tag <hrsTrabAntesAcid>
	cHrsTrabAntesAcid := StrTran( M->TNC_HRTRAB, ":", "" )

	//Busca da informa��o a ser enviada na tag <tpCat>
	cTpCat := M->TNC_TIPCAT

	//Busca da informa��o a ser enviada na tag <indCatObito>
	cIndCatObito := IIf( M->TNC_MORTE == "1", "S", "N" )

	//Busca da informa��o a ser enviada na tag <dtObito>
	dDtObito := M->TNC_DTOBIT

	//Busca da informa��o a ser enviada na tag <indComunPolicia>
	cIndComunPolicia := IIf( M->TNC_POLICI == "1", "S", "N" )

	//Busca da informa��o a ser enviada na tag <codSitGeradora>
	If X3USO( GetSx3Cache( "TNG_ESOC", "X3_USADO" ) )
		If !Empty( Posicione( "TNG", 1, xFilial( "TNG" ) + M->TNC_TIPACI, "TNG_ESOC" ) )
			cCodSitGeradora	:= Posicione( "TNG", 1, xFilial( "TNG" ) + M->TNC_TIPACI, "TNG_ESOC" )
		EndIf
	Else
		If !Empty( Posicione( "TNG", 1, xFilial( "TNG" ) + M->TNC_TIPACI, "TNG_ESOC1" ) )
			cCodSitGeradora	:= Posicione( "TNG", 1, xFilial( "TNG" ) + M->TNC_TIPACI, "TNG_ESOC1" )
		EndIf
	EndIf

	//Busca da informa��o a ser enviada na tag <obsCAT>
	cObsCat := Alltrim( MDTSubTxt( Upper( SubStr( M->TNC_DETALH, 1, 999 ) ) ) )

	//Busca da informa��o a ser enviada na tag <tpLocal>
	cTpLocal := M->TNC_INDLOC

	//-------Indica Localiza��o-------
	// 1 - Estab da Empresa;    	1 - Estabelecimento do empregador no Brasil;
	// 2 - Onde Presta Servi�o;		3 - Estabelecimento de terceiros onde o empregador presta servi�os;
	// 3 - Via Publica;				4 - Via p�blica;
	// 4 - Area Rural; 				5 - �rea rural;
	// 5 - Embarca��o				6 - Embarca��o;
	// 6 - Exterior					2 - Estabelecimento do empregador no Exterior;
	// 9 - Outros;					9 - Outros.
	//--------------------------------
	Do Case
		Case cTpLocal == "2" ; cTpLocal := "3"
		Case cTpLocal == "3" ; cTpLocal := "4"
		Case cTpLocal == "4" ; cTpLocal := "5"
		Case cTpLocal == "5" ; cTpLocal := "6"
		Case cTpLocal == "6" ; cTpLocal := "2"
	End Case

	//Busca da informa��o a ser enviada na tag <dscLocal>
	cDscLocal := Alltrim( MDTSubTxt( M->TNC_LOCAL ) )

	//Busca da informa��o a ser enviada na tag <tpLograd>
	cTpLograd := AllTrim( M->TNC_TPLOGR )

	//Busca da informa��o a ser enviada na tag <dscLograd>
	cDscLograd := Alltrim( MDTSubTxt( M->TNC_DESLOG ) )

	//Busca da informa��o a ser enviada na tag <nrLograd>
	cNrLograd := IIf( !Empty( M->TNC_NUMLOG ), cValtoChar( M->TNC_NUMLOG ), "S/N" )

	//Busca da informa��o a ser enviada na tag <complemento>
	cComplemento := AllTrim( MDTSubTxt( M->TNC_COMPL ) )

	//Busca da informa��o a ser enviada na tag <bairro>
	cBairro := AllTrim( MDTSubTxt( M->TNC_BAIRRO ) )

	//Busca da informa��o a ser enviada na tag <cep>
	cCEP := M->TNC_CEP

	//Busca da informa��o a ser enviada na tag <codMunic>
	If lMiddleware //Caso for envio pelo Middleware, comp�e o c�digo do estado junto com o da cidade
		Do Case
			Case M->TNC_ESTACI = "AC" ; cCodUF := "12"
			Case M->TNC_ESTACI = "AL" ; cCodUF := "27"
			Case M->TNC_ESTACI = "AP" ; cCodUF := "16"
			Case M->TNC_ESTACI = "AM" ; cCodUF := "13"
			Case M->TNC_ESTACI = "BA" ; cCodUF := "29"
			Case M->TNC_ESTACI = "CE" ; cCodUF := "23"
			Case M->TNC_ESTACI = "DF" ; cCodUF := "53"
			Case M->TNC_ESTACI = "ES" ; cCodUF := "32"
			Case M->TNC_ESTACI = "GO" ; cCodUF := "52"
			Case M->TNC_ESTACI = "MA" ; cCodUF := "21"
			Case M->TNC_ESTACI = "MT" ; cCodUF := "51"
			Case M->TNC_ESTACI = "MS" ; cCodUF := "50"
			Case M->TNC_ESTACI = "MG" ; cCodUF := "31"
			Case M->TNC_ESTACI = "PA" ; cCodUF := "15"
			Case M->TNC_ESTACI = "PB" ; cCodUF := "25"
			Case M->TNC_ESTACI = "PR" ; cCodUF := "41"
			Case M->TNC_ESTACI = "PE" ; cCodUF := "26"
			Case M->TNC_ESTACI = "PI" ; cCodUF := "22"
			Case M->TNC_ESTACI = "RN" ; cCodUF := "24"
			Case M->TNC_ESTACI = "RS" ; cCodUF := "43"
			Case M->TNC_ESTACI = "RJ" ; cCodUF := "33"
			Case M->TNC_ESTACI = "RO" ; cCodUF := "11"
			Case M->TNC_ESTACI = "RR" ; cCodUF := "14"
			Case M->TNC_ESTACI = "SC" ; cCodUF := "42"
			Case M->TNC_ESTACI = "SP" ; cCodUF := "35"
			Case M->TNC_ESTACI = "SE" ; cCodUF := "28"
			Case M->TNC_ESTACI = "TO" ; cCodUF := "17"
		End Case

		If !Empty( M->TNC_CODCID ) //Caso o usu�rio tenha informado uma cidade no cadastro, adiciona o c�digo da UF
			cCodMunic := cCodUF + M->TNC_CODCID
		EndIf
	Else
		cCodMunic := M->TNC_CODCID
	EndIf

	//Busca da informa��o a ser enviada na tag <uf>
	cUFAci := M->TNC_ESTACI

	//Busca da informa��o a ser enviada na tag <pais>
	cCodPai := Posicione( "C08", 3, xFilial( "C08" ) + M->TNC_CODPAI, "C08_PAISSX" ) //Pega o c�digo esperado pelo eSocial

	//Busca da informa��o a ser enviada na tag <codPostal>
	cCodPostal := M->TNC_CODPOS

	//Busca da informa��o a ser enviada na tag <tpInsc>
	cTpInscAci := M->TNC_TPINS

	//------- Tipos de Inscri��o -------
	//	1- CNPJ			1- CNPJ
	//	2- CAEPF		3- CAEPF
	//	3- CNO			4- CNO
	//-----------------------------------
	Do Case
		Case cTpInscAci == "2" ; cTpInscAci := "3"
		Case cTpInscAci == "3" ; cTpInscAci := "4"
	End Case

	//Busca da informa��o a ser enviada na tag <nrInsc>
	cNrInscAci := M->TNC_CGCPRE

	//Busca da informa��o a ser enviada nas tags <codParteAting> e <lateralidade>
	If lAcidente
		oParte := oModelTNC:GetModel( 'TNMPARTE' )
		nLenGrid := oParte:Length()

		For nCont := 1 To nLenGrid //Percorre a Grid para buscar todas as Partes Atingidas
			oParte:GoLine( nCont ) //Posiciona na linha desejada.
			If !( oParte:IsDeleted() ) .And. !Empty( oParte:GetValue( "TYF_CODPAR" ) ) //Verifica se registro n�o est� deletado.
				aAdd( aParte, { Posicione( "TOI", 1, xFilial( "TOI" ) + oParte:GetValue( "TYF_CODPAR" ), "TOI_ESOC" ), oParte:GetValue( "TYF_LATERA" ) } )
				Exit //Sai do la�o pra adicionar apenas uma parte (leiaute do eSocial permite apenas uma parte atingida)
			EndIf
		Next nCont
	Else
		dbSelectArea( "TYF" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TYF" ) + M->TNC_ACIDEN )
			While !Eof() .And. TYF->TYF_FILIAL == xFilial( "TYF" ) .And. TYF->TYF_ACIDEN == M->TNC_ACIDEN
				aAdd( aParte, { Posicione( "TOI", 1, xFilial( "TOI" ) + TYF->TYF_CODPAR, "TOI_ESOC" ), TYF->TYF_LATERA } )
				Exit //Sai do la�o pra adicionar apenas uma parte (leiaute do eSocial permite apenas uma parte atingida)
				TYF->( dbSkip() )
			End
		EndIf
	EndIf

	//Busca da informa��o a ser enviada na tag <codAgntCausador>
	If lAcidente
		oCausa	 := oModelTNC:GetModel( 'TNMCAUSA' )
		nLenGrid := oCausa:Length()

		For nCont := 1 To nLenGrid // Percorre a Grid para buscar todas as Causa de Acidente
			oCausa:GoLine( nCont ) //Posiciona na linha desejada.
			If !( oCausa:IsDeleted() ) .And. !Empty( oCausa:GetValue( "TYE_CAUSA" ) ) //Verifica se registro n�o est� deletado.
				aAdd( aCausa, { Posicione( "TNH", 1, xFilial( "TNH" ) + oCausa:GetValue( "TYE_CAUSA" ), "TNH_ESOC" ) } )
				Exit //Sai do la�o pra adicionar apenas um agente (leiaute do eSocial permite apenas um agente causador)
			EndIf
		Next nCont
	Else
		dbSelectArea( "TYE" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TYE" ) + M->TNC_ACIDEN )
			While !Eof() .And. TYE->TYE_FILIAL == xFilial( "TYE" ) .And. TYE->TYE_ACIDEN == M->TNC_ACIDEN
				aAdd( aCausa, { Posicione( "TNH", 1, xFilial( "TNH" ) + TYE->TYE_CAUSA, "TNH_ESOC" ) } )
				Exit //Sai do la�o pra adicionar apenas um agente (leiaute do eSocial permite apenas um agente causador)
				TYE->( dbSkip() )
			End
		EndIf
	EndIf

	//Busca as informa��es referentes ao atendimento m�dico do acidente
	aInfAten := MDTInfAte()

	//Busca da informa��o a ser enviada na tag <dtAtendimento>
	dDtAtendimento := IIf( Len( aInfAten ) > 0, aInfAten[ 1 ], SToD( "" ) )

	//Busca da informa��o a ser enviada na tag <hrAtendimento>
	cHrAtendimento := IIf( Len( aInfAten ) > 0, aInfAten[ 2 ], "" )

	//Busca da informa��o a ser enviada na tag <indInternacao>
	cIndInternacao := IIf( Len( aInfAten ) > 0, IIf( M->TNC_INTERN == "1", "S", "N" ), "" )

	//Busca da informa��o a ser enviada na tag <durTrat>
	cDurTrat := IIf( Len( aInfAten ) > 0, aInfAten[ 3 ], "" )

	//Busca da informa��o a ser enviada na tag <indAfast>
	cIndAfast := IIf( Len( aInfAten ) > 0, aInfAten[ 4 ], "" )

	//Busca da informa��o a ser enviada na tag <dscLesao>
	cDscLesao := IIf( Len( aInfAten ) > 0, Posicione( "TOJ", 1, xFilial( "TOJ" ) + M->TNC_CODLES, "TOJ_ESOC" ), "" )

	//Busca da informa��o a ser enviada na tag <dscCompLesao>
	cDscCompLesao := IIf( Len( aInfAten ) > 0, Alltrim( MDTSubTxt( M->TNC_DESLES ) ), "" )

	//Busca da informa��o a ser enviada na tag <diagProvavel>
	cDiagProvavel := IIf( Len( aInfAten ) > 5, aInfAten[ 6 ], "" )

	//Busca da informa��o a ser enviada na tag <codCID>
	cCodCID := IIf( Len( aInfAten ) > 0, aInfAten[ 5 ], "" )

	//Busca da informa��o a ser enviada na tag <observacao>
	cObservacao := IIf( Len( aInfAten ) > 5, aInfAten[ 7 ], "" )

	//Busca da informa��o a ser enviada na tag <nmEmit>
	cNmEmit := IIf( Len( aInfAten ) > 5, aInfAten[ 8 ], "" )

	//Busca da informa��o a ser enviada na tag <ideOC>
	cIdeOC := IIf( Len( aInfAten ) > 5, aInfAten[ 9 ], "" )

	//Busca da informa��o a ser enviada na tag <nrOC>
	cNrOC := IIf( Len( aInfAten ) > 5, aInfAten[ 10 ], "" )

	//Busca da informa��o a ser enviada na tag <ufOC>
	cUfOC := IIf( Len( aInfAten ) > 5, aInfAten[ 11 ], "" )

	//Busca da informa��o a ser utilizada no relat�rio de inconsist�ncias referente ao c�digo do m�dico/dentista emitente do atestado
	cCodMedico := IIf( Len( aInfAten ) > 5, aInfAten[ 12 ], "" )

	//Realiza a verifica��o das inconsist�ncias ou carrega o Xml
	If lIncons
		fInconsis( @aIncEnv ) //Verifica as inconsist�ncias das informa��es a serem enviadas
	Else
		cRet := fCarrCAT( cValToChar( nOper ), cChave ) //Carrega o Xml

		//Caso for integra��o via SIGATAF e a chave do registro tenha sido alterada (altera��o da data, hora ou tipo do acidente)
		If !lMiddleware .And. !Empty( cChvNov ) .And. cChave <> cChvNov

			//Verifica se o acidente teve a data, hora ou tipo alterados e busca o TAFKEY do registro
			cTAFKey := MDTGetTKEY( cChave )

		EndIf

	EndIf

	RestArea( aAreaTNC )
	RestArea( aArea )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarrCAT
Monta o Xml da CAT para envio ao Governo

@return	cXml, Caracter, Estrutura XML a ser enviada para o SIGATAF/Middleware

@sample	fCarrCAT( "3" )

@param cOper, Caracter, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE

@author	Luis Fellipy Bett
@since	30/08/2018
/*/
//---------------------------------------------------------------------
Static Function fCarrCAT( cOper, cChave )

	Local cXml	:= ""
	Local nCont	:= 0

	Default cOper := "3"

	//Cria o cabe�alho do Xml com o ID, informa��es do Evento e Empregador
	MDTGerCabc( @cXml, "S2210", cOper, cChave )

	//TRABALHADOR
	cXml += 		'<ideVinculo>'
	cXml += 			'<cpfTrab>'		+ cCpfTrab		+ '</cpfTrab>' //Obrigat�rio
	If !MDTVerTSVE( cCodCateg ) //Caso n�o for TSVE
		cXml +=			'<matricula>'	+ cMatricula	+ '</matricula>' //Obrigat�rio
	Else
		cXml +=			'<codCateg>'	+ cCodCateg		+ '</codCateg>' //Obrigat�rio
	EndIf
	cXml += 		'</ideVinculo>'
	//COMUNICA��O DE ACIDENTE DE TRABALHO
	cXml += 		'<cat>'
	cXml += 			'<dtAcid>'				+ MDTAjsData( dDtAcid )		+ '</dtAcid>' //Obrigat�rio
	cXml += 			'<tpAcid>'				+ cTpAcid					+ '</tpAcid>' //Obrigat�rio
	If cTpAcid != "2" .And. !Empty( cHrAcid ) //Se for acidente t�pico ou de trajeto e a hora estiver preenchida
		cXml +=			'<hrAcid>'				+ cHrAcid					+ '</hrAcid>'
	EndIf
	If cTpAcid != "2" .And. !Empty( cHrsTrabAntesAcid ) //Se for acidente t�pico ou de trajeto e a hora estiver preenchida
		cXml +=			'<hrsTrabAntesAcid>'	+ cHrsTrabAntesAcid			+ '</hrsTrabAntesAcid>'
	EndIf
	cXml += 			'<tpCat>'				+ cTpCat					+ '</tpCat>' //Obrigat�rio
	cXml += 			'<indCatObito>'			+ cIndCatObito				+ '</indCatObito>' //Obrigat�rio
	If cIndCatObito == "S"
		cXml += 		'<dtObito>'				+ MDTAjsData( dDtObito )	+ '</dtObito>'
	EndIf
	cXml += 			'<indComunPolicia>'		+ cIndComunPolicia			+ '</indComunPolicia>' //Obrigat�rio
	cXml += 			'<codSitGeradora>'		+ cCodSitGeradora			+ '</codSitGeradora>' //Obrigat�rio
	cXml += 			'<iniciatCAT>'			+ "1" 						+ '</iniciatCAT>' //Obrigat�rio
	If !Empty( cObsCat )
		cXml +=			'<obsCAT>'				+ cObsCat 					+ '</obsCAT>'
	EndIf
	cXml += 			'<localAcidente>'
	cXml += 				'<tpLocal>'			+ cTpLocal					+ '</tpLocal>' //Obrigat�rio
	If !Empty( cDscLocal )
		cXml += 			'<dscLocal>'		+ cDscLocal					+ '</dscLocal>'
	EndIf
	If !Empty( cTpLograd )
		cXml += 			'<tpLograd>'		+ cTpLograd					+ '</tpLograd>'
	EndIf
	cXml += 				'<dscLograd>'		+ cDscLograd				+ '</dscLograd>' //Obrigat�rio
	cXml += 				'<nrLograd>'		+ cNrLograd					+ '</nrLograd>' //Obrigat�rio
	If !Empty( cComplemento )
		cXml += 			'<complemento>'		+ cComplemento				+ '</complemento>'
	EndIf
	If !Empty( cBairro )
		cXml += 			'<bairro>'			+ cBairro					+ '</bairro>'
	EndIf
	If cTpLocal $ "1/3/5" //Se for "Estabelecimento do empregador no Brasil", "Estabelecimento de terceiros" ou "�rea rural"
		cXml += 			'<cep>'				+ cCEP						+ '</cep>'
	EndIf
	If cTpLocal $ "1/3/4/5" //Se for "Estabelecimento do empregador no Brasil", "Estabelecimento de terceiros", "Via P�blica" ou "�rea rural"
		cXml += 			'<codMunic>'		+ cCodMunic 				+ '</codMunic>'
		cXml += 			'<uf>'				+ cUFAci 					+ '</uf>'
	EndIf
	If cTpLocal == "2" //Se for "Estabelecimento do empregador no Exterior"
		cXml += 			'<pais>'			+ cCodPai	 				+ '</pais>'
		cXml += 			'<codPostal>'		+ cCodPostal				+ '</codPostal>'
	EndIf
	If !Empty( cTpInscAci ) .And. !Empty( cNrInscAci )
		cXml += 			'<ideLocalAcid>'
		cXml += 				'<tpInsc>' 		+ cTpInscAci			+ '</tpInsc>'
		cXml += 				'<nrInsc>' 		+ cNrInscAci			+ '</nrInsc>'
		cXml += 			'</ideLocalAcid>'
	EndIf
	cXml += 			'</localAcidente>'

	For nCont := 1 To Len( aParte )
		cXml += 		'<parteAtingida>'
		cXml += 			'<codParteAting>'	+ aParte[ nCont, 1 ] + '</codParteAting>' //Obrigat�rio
		cXml += 			'<lateralidade>'	+ aParte[ nCont, 2 ] + '</lateralidade>' //Obrigat�rio
		cXml += 		'</parteAtingida>'
	Next nCont

	For nCont := 1 To Len( aCausa )
		cXml += 		'<agenteCausador>'
		cXml += 			'<codAgntCausador>' + aCausa[ nCont, 1 ] + '</codAgntCausador>' //Obrigat�rio
		cXml += 		'</agenteCausador>'
	Next nCont

	//Caso exista informa��es de atestado a serem enviadas
	If Len( aInfAten ) > 0 .Or. !lMiddleware //Caso existam informa��es de atendimento ou seja envio pelo SIGATAF, envia
		cXml += 		'<atestado>'
		cXml += 			'<dtAtendimento>'	+ MDTAjsData( dDtAtendimento )	+ '</dtAtendimento>'
		cXml += 			'<hrAtendimento>'	+ cHrAtendimento				+ '</hrAtendimento>'
		cXml += 			'<indInternacao>'	+ cIndInternacao				+ '</indInternacao>'
		cXml +=				'<durTrat>'			+ cDurTrat						+ '</durTrat>'
		cXml += 			'<indAfast>'		+ cIndAfast						+ '</indAfast>'
		cXml += 			'<dscLesao>'		+ cDscLesao						+ '</dscLesao>'
		If !Empty( cDscCompLesao ) .Or. !lMiddleware
			cXml +=			'<dscCompLesao>'	+ cDscCompLesao					+ '</dscCompLesao>'
		EndIf
		If !Empty( cDiagProvavel ) .Or. !lMiddleware
			cXml +=			'<diagProvavel>'	+ cDiagProvavel					+ '</diagProvavel>'
		EndIf
		cXml += 			'<codCID>'			+ cCodCID						+ '</codCID>'
		If !Empty( cObservacao ) .Or. !lMiddleware
			cXml +=			'<observacao>'		+ cObservacao					+ '</observacao>'
		EndIf
		cXml += 			'<emitente>'
		cXml += 				'<nmEmit>'		+ AllTrim( MDTSubTxt( cNmEmit ) )	+ '</nmEmit>'
		cXml += 				'<ideOC>'		+ cIdeOC 							+ '</ideOC>'
		cXml += 				'<nrOC>' 		+ cNrOC 							+ '</nrOC>'
		If !Empty( cUfOC ) //Caso esteja preenchido
			cXml += 			'<ufOC>' 		+ cUfOC 							+ '</ufOC>'
		EndIf
		cXml += 			'</emitente>'
		cXml += 		'</atestado>'
	EndIf

	//Caso tenha encontrado uma CAT Origem para a CAT atual
	If !Empty( cNrRecCatOrig )
		cXml += '		<catOrigem>'
		cXml += '			<nrRecCatOrig>' + cNrRecCatOrig + '</nrRecCatOrig>'
		cXml += '		</catOrigem>'
	EndIf

	cXml += 		'</cat>'
	cXml += 	'</evtCAT>'
	cXml += '</eSocial>'

Return cXml

//---------------------------------------------------------------------
/*/{Protheus.doc} fInconsis
Valida as informa��es a serem enviadas para o SIGATAF/Middleware

@return	Nil, Nulo

@sample	fInconsis( aIncEnv )

@param	aIncEnv, Array, Array passado por refer�ncia que ir� receber os logs de inconsist�ncias (se houver)

@author Luis Fellipy Bett
@since	30/08/2018 - Refatorada em: 17/02/2021
/*/
//---------------------------------------------------------------------
Static Function fInconsis( aIncEnv )

	//Vari�veis de controle
	Local aArea	  := GetArea()
	Local cFilBkp := cFilAnt
	Local lVldFun := .T. //Vari�vel de controle de valida��o do funcion�rio

	//Vari�veis de contadores
	Local nCont := 0

	//Vari�veis de composi��o de informa��es
	Local cStrFil  := STR0084 + ": " + AllTrim( cFilEnv ) //Filial: XXX
	Local cStrFunc := STR0001 + ": " + AllTrim( cNumMat ) + " - " + AllTrim( cNomeFun ) //Funcion�rio: XXX - XXXXX
	Local cStrAci  := STR0002 + ": " + AllTrim( M->TNC_ACIDEN ) //Acidente: XXX
	Local cStrEmi  := STR0003 + ": " + AllTrim( cCodMedico ) + " - " + AllTrim( cNmEmit ) //Emitente: XXX - XXXXX

	//Seta a filial de envio para as valida��es de tabelas do TAF
	cFilAnt := cFilEnv

	Help := .T. //Desativa as mensagens de Help

	//Valida��o de ficha m�dica relacionada ao acidente
	If ( lAtestado .Or. lDiagnostico ) .And. Empty( M->TNC_NUMFIC )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0012 ) //Acidente: XXX / O acidente selecionado n�o possui nenhuma ficha m�dica vinculada
		aAdd( aIncEnv, '' )
		lVldFun := .F. //Caso o acidente n�o possuir um funcion�rio vinculado, n�o valida as informa��es dele
	EndIf

	//Valida��o da tag <cpfTrab> - CPF do trabalhador
	//Preencher com o n�mero do CPF do trabalhador.
	//Informa��o obrigat�ria.
	If lVldFun .And. Empty( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0013 + ": " + STR0006 ) //Funcion�rio: XXX - XXXXX / CPF: Em branco
		aAdd( aIncEnv, '' )
	ElseIf lVldFun .And. !CHKCPF( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0013 + ": " + cCpfTrab ) //Funcion�rio: XXX - XXXXX / CPF: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0011 ) //Valida��o: Deve ser um n�mero de CPF v�lido
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <matricula> - Matr�cula atribu�da ao trabalhador pela empresa
	//Deve corresponder � matr�cula informada pelo empregador no evento S-2190, S-2200 ou S-2300 do respectivo contrato. N�o preencher no caso de
	//Trabalhador Sem V�nculo de Emprego/Estatut�rio - TSVE sem informa��o de matr�cula no evento S-2300
	//A valida��o de exist�ncia de um registro S-2190, S-2200 ou S-2300 j� � realizada no come�o do envio, atrav�s da fun��o MDTVld2200

	//Valida��o da tag <codCateg> - C�digo da categoria do trabalhador
	//Informa��o obrigat�ria e exclusiva se n�o houver preenchimento de matricula. Se informado, deve ser um c�digo v�lido e existente na Tabela 01.
	If lVldFun .And. Empty( cMatricula ) .And. Empty( cCodCateg )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0014 + ": " + STR0006 ) //Funcion�rio: XXX - XXXXX / Categoria: Em branco
		aAdd( aIncEnv, '' )
	ElseIf lVldFun .And. Empty( cMatricula ) .And. !ExistCPO( "C87", cCodCateg, 2 )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0014 + ": " + cCodCateg ) //Funcion�rio: XXX - XXXXX / Categoria: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0015 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 01 do eSocial
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <dtAcid> - Data do acidente
	//Deve ser uma data v�lida, igual ou anterior � data atual e igual ou posterior � data de admiss�o do trabalhador e � data de in�cio da
	//obrigatoriedade deste evento para o empregador no eSocial. Se tpCat = [2, 3], deve ser informado valor igual ao preenchido no evento de
	//CAT anterior, quando informado em nrRecCatOrig.
	//Informa��o obrigat�ria.
	If Empty( dDtAcid )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0016 + ": " + STR0006 ) //Acidente: XXX / Data do Acidente: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( dDtAcid >= dDtEsoc .And. dDtAcid >= dDtAdm .And. dDtAcid <= dDataBase )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0016 + ": " + DToC( dDtAcid ) ) //Acidente: XXX / Data do Acidente: XX/XX/XXXX
		aAdd( aIncEnv, STR0007 + ": " + STR0017 + ":" ) //Valida��o: Deve ser uma data v�lida e:
		aAdd( aIncEnv, "* " + STR0018 + ": " + DToC( dDataBase ) ) //* Igual ou anterior � data atual: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0019 + ": " + DToC( dDtAdm ) ) //* Igual ou posterior � data de admiss�o do trabalhador: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0020 + ": " + DToC( dDtEsoc ) ) //* Igual ou posterior � data de in�cio de obrigatoriedade dos eventos de SST ao eSocial: XX/XX/XXXX
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <tpAcid> - Tipo de acidente de trabalho
	//Valores v�lidos: 1 - T�pico, 2 - Doen�a ou 3 - Trajeto
	//Informa��o obrigat�ria.
	If Empty( cTpAcid )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0021 + ": " + STR0006 ) //Acidente: XXX / Tipo do Acidente: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cTpAcid $ "1/2/3" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0021 + ": " + cTpAcid ) //Acidente: XXX / Tipo do Acidente: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0022 ) //Valida��o: Deve ser igual a 1- T�pico, 2- Doen�a ou 3- Trajeto
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <hrAcid> - Hora do acidente
	//Preenchimento obrigat�rio se tpAcid = [1] ou se (tpAcid = [3] e dtAcid >= [2022-01-26]). N�o informar
	//se tpAcid = [2]. Se preenchida, deve estar no intervalo entre [0000] e [2359], criticando inclusive a segunda parte
	//do n�mero, que indica os minutos, que deve ser menor ou igual a 59. Se tpCat = [2, 3], deve ser informado valor igual ao
	//preenchido no evento de CAT anterior, quando informado em nrRecCatOrig.
	If ( cTpAcid == "1" .Or. ( cTpAcid == "3" .And. dDtAcid >= SToD( "20220126" ) ) ) .And. Empty( cHrAcid )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0023 + ": " + STR0006 ) //Acidente: XXX / Hora do Acidente: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <hrsTrabAntesAcid> - Horas trabalhadas antes da ocorr�ncia do acidente
	//Preenchimento obrigat�rio se tpAcid = [1] ou se (tpAcid = [3] e dtAcid >= [2022-07-20]). N�o informar 
	//se tpAcid = [2]. Se preenchida, deve estar no intervalo entre [0000] e [9959], criticando inclusive a segunda parte
	//do n�mero, que indica os minutos, que deve ser menor ou igual a 59.
	If ( cTpAcid == "1" .Or. ( cTpAcid == "3" .And. dDtAcid >= SToD( "20220720" ) ) ) .And. ( Empty( cHrsTrabAntesAcid ) .Or. AllTrim( cHrsTrabAntesAcid ) == ":" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0024 + ": " + STR0006 ) //Acidente: XXX / Horas Trabalhadas Antes do Acidente: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <tpCat> - Tipo de CAT
	//Valores v�lidos: 1 - Inicial, 2 - Reabertura ou 3 - Comunica��o de �bito
	//Informa��o obrigat�ria.
	If Empty( cTpCat )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0025 + ": " + STR0006 ) //Acidente: XXX / Tipo de CAT: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cTpCat $ "1/2/3" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0025 + ": " + cTpCat ) //Acidente: XXX / Tipo de CAT: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0026 ) //Valida��o: Deve ser igual a 1- Inicial, 2- Reabertura ou 3- Comunica��o de �bito
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <indCatObito> - Houve �bito?
	//Valores v�lidos: S - Sim ou N - N�o. Valida��o: Se o tpCat for igual a [3], o campo dever� sempre ser preenchido com [S]. Se o tpCat for
	//igual a [2], o campo dever� sempre ser preenchido com [N].
	//Informa��o obrigat�ria.
	If Empty( cIndCatObito )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0027 + ": " + STR0006 ) //Acidente: XXX / Indicativo de �bito: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cIndCatObito $ "S/N" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0027 + ": " + cIndCatObito ) //Acidente: XXX / Indicativo de �bito: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0028 ) //Valida��o: Deve ser igual a S- Sim ou N- N�o
		aAdd( aIncEnv, '' )
	ElseIf cTpCat == "3" .And. !( cIndCatObito == "S" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0027 + ": " + cIndCatObito ) //Acidente: XXX / Indicativo de �bito: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0029 ) //Valida��o: Se o Tipo de CAT for igual a 3- Comunica��o de �bito, o campo 'Houve Morte' deve ser igual a 'Sim'
		aAdd( aIncEnv, '' )
	ElseIf cTpCat == "2" .And. !( cIndCatObito == "N" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0027 + ": " + cIndCatObito ) //Acidente: XXX / Indicativo de �bito: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0030 ) //Valida��o: Se o Tipo de CAT for igual a 2- Reabertura, o campo 'Houve Morte' deve ser igual a 'N�o'
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <dtObito> - Data do �bito
	//Valida��o: Deve ser uma data v�lida, igual ou posterior a dtAcid e igual ou anterior � data atual. Preenchimento obrigat�rio e exclusivo
	//se indCatObito = [S].
	If cIndCatObito == "S"
		If !( dDtObito >= dDtAcid .And. dDtObito <= dDataBase )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0031 + ": " + DToC( dDtObito ) ) //Acidente: XXX / Data do �bito: XX/XX/XXXX
			aAdd( aIncEnv, STR0007 + ": " + STR0017 + ":" ) //Valida��o: Deve ser uma data v�lida e:
			aAdd( aIncEnv, "* " + STR0032 + ": " + DToC( dDtAcid ) ) //* Igual ou posterior � data do acidente: XX/XX/XXXX
			aAdd( aIncEnv, "* " + STR0018 + ": " + DToC( dDataBase ) ) //* Igual ou anterior � data atual: XX/XX/XXXX
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <indComunPolicia> - Houve comunica��o � autoridade policial?
	//Valores v�lidos: S - Sim ou N - N�o
	//Informa��o obrigat�ria.
	If Empty( cIndComunPolicia )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0033 + ": " + STR0006 ) //Acidente: XXX / Indicativo de Comunica��o � Autoridade Policial: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cIndComunPolicia $ "S/N" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0033 + ": " + cIndComunPolicia ) //Acidente: XXX / Indicativo de Comunica��o � Autoridade Policial: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0028 ) //Valida��o: Deve ser igual a S- Sim ou N- N�o
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <codSitGeradora> - C�digo da situa��o geradora do acidente ou da doen�a profissional.
	//Valida��o: Deve ser um c�digo v�lido e existente na Tabela 15 ou na Tabela 16.
	//Informa��o obrigat�ria.
	If Empty( cCodSitGeradora )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0034 + ": " + STR0006 ) //Acidente: XXX / C�digo da Situa��o Geradora: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !ExistCPO( "C8K", cCodSitGeradora, 2 )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0034 + ": " + cCodSitGeradora ) //Acidente: XXX / C�digo da Situa��o Geradora: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0035 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 15 do eSocial
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <iniciatCAT> - Iniciativa da CAT.
	//Valores v�lidos: 1 - Empregador, 2 - Ordem judicial ou 3 - Determina��o de �rg�o fiscalizador
	//Chumbado para ser enviado sempre como '1'

	//Valida��o da tag <obsCAT> - Observa��o.
	//N�o possui nenhuma valida��o espec�fica

	//Valida��o da tag <tpLocal> - Tipo de local do acidente.
	//Valores v�lidos: 1 - Estabelecimento do empregador no Brasil, 2 - Estabelecimento do empregador no exterior, 3 - Estabelecimento de terceiros
	//onde o empregador presta servi�os, 4 - Via p�blica, 5 - �rea rural, 6 - Embarca��o ou 9 - Outros
	//Informa��o obrigat�ria.
	If Empty( cTpLocal )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0036 + ": " + STR0006 ) //Acidente: XXX / Tipo de Local do Acidente: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cTpLocal $ "1/2/3/4/5/6/9" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0036 + ": " + cTpLocal ) //Acidente: XXX / Tipo de Local do Acidente: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0037 + ":" ) //Valida��o: Deve ser igual a:
		aAdd( aIncEnv, STR0038 ) //1- Estabelecimento do empregador no Brasil
		aAdd( aIncEnv, STR0039 ) //2- Estabelecimento do empregador no exterior
		aAdd( aIncEnv, STR0040 ) //3- Estabelecimento de terceiros onde o empregador presta servi�os
		aAdd( aIncEnv, STR0041 ) //4- Via p�blica
		aAdd( aIncEnv, STR0042 ) //5- �rea rural
		aAdd( aIncEnv, STR0043 ) //6- Embarca��o
		aAdd( aIncEnv, STR0044 ) //9- Outros
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <dscLocal> - Especifica��o do local do acidente (p�tio, rampa de acesso, posto de trabalho, etc.).
	//N�o possui nenhuma valida��o espec�fica

	//Valida��o da tag <tpLograd> - Tipo de logradouro.
	//Valida��o: Se informado, deve ser um c�digo v�lido e existente na Tabela 20.
	If !Empty( cTpLograd ) .And. !ExistCPO( "C06", cTpLograd, 4 )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0045 + ": " + cTpLograd ) //Acidente: XXX / Tipo de Logradouro: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0046 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 20 do eSocial
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <dscLograd> - Descri��o do logradouro.
	//Informa��o obrigat�ria.
	If Empty( cDscLograd )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0047 + ": " + STR0006 ) //Acidente: XXX / Descri��o do Logradouro: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <nrLograd> - N�mero do logradouro.
	//Se n�o houver n�mero a ser informado, preencher com "S/N".
	//Caso o campo TNC_NUMLOG esteja preenchido envia o conte�do dele, sen�o envia 'S/N'

	//Valida��o da tag <complemento> - Complemento do logradouro.
	//N�o possui nenhuma valida��o espec�fica

	//Valida��o da tag <bairro> - Nome do bairro/distrito.
	//N�o possui nenhuma valida��o espec�fica

	//Valida��o da tag <cep> - C�digo de Endere�amento Postal - CEP.
	//Valida��o: Preenchimento obrigat�rio se tpLocal = [1, 3, 5]. N�o preencher se tpLocal = [2]. Se preenchido, deve ser informado apenas com
	//n�meros, com 8 (oito) posi��es.
	If cTpLocal $ "1/3/5"
		If Empty( cCEP )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0048 + ": " + STR0006 ) //Acidente: XXX / CEP: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <codMunic> - c�digo do munic�pio, conforme tabela do IBGE.
	//Valida��o: Preenchimento obrigat�rio se tpLocal = [1, 3, 4, 5]. N�o preencher se tpLocal = [2]. Se informado, deve ser um c�digo v�lido
	//e existente na tabela do IBGE.
	If cTpLocal $ "1/3/4/5"
		If Empty( cCodMunic )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0049 + ": " + STR0006 ) //Acidente: XXX / Munic�pio: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <uf> - Sigla da Unidade da Federa��o - UF.
	//Valores v�lidos: AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO.
	//Valida��o: Preenchimento obrigat�rio se tpLocal = [1, 3, 4, 5]. N�o preencher se tpLocal = [2].
	If cTpLocal $ "1/3/4/5"
		If Empty( cUFAci )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0050 + ": " + STR0006 ) //Acidente: XXX / UF: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <pais> - C�digo do pa�s.
	//Valida��o: Deve ser um c�digo de pa�s v�lido e existente na Tabela 06. Preenchimento obrigat�rio se tpLocal = [2]. N�o preencher nos
	//demais casos.
	If cTpLocal == "2"
		If Empty( cCodPai )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0051 + ": " + STR0006 ) //Acidente: XXX / Pa�s: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !ExistCPO( "C08", cCodPai, 4 )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0051 + ": " + cCodPai ) //Acidente: XXX / Pa�s: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0052 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 06 do eSocial
			aAdd( aIncEnv, '' )
		ElseIf cCodPai $ "008/009/020/025/047/100/106/131/150/151/152/237/263/358/367/388/395/396/423/452/490/563/569/583/678/738/785/790/840/855/873/895" //Pa�ses extintos de acordo com o leiaute do eSocial
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0051 + ": " + cCodPai + " - " + AllTrim( Posicione( xFilial( "C08" ), 4, xFilial( "C08" ) + cCodPai, "C08_DESCRI" ) ) ) //Acidente: XXX / Pa�s: XXX - XXXXX
			aAdd( aIncEnv, STR0007 + ": " + STR0083 ) //Valida��o: O pa�s selecionado est� extinto de acordo com o leiaute do eSocial
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <codPostal> - C�digo de Endere�amento Postal.
	//Valida��o: Preenchimento obrigat�rio se tpLocal = [2]. N�o preencher nos demais casos.
	If cTpLocal == "2"
		If Empty( cCodPostal )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0053 + ": " + STR0006 ) //Acidente: XXX / C�digo de Endere�amento Postal: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <tpInsc> - c�digo correspondente ao tipo de inscri��o do local onde ocorreu o acidente ou a doen�a ocupacional,
	//conforme Tabela 05.
	//Valida��o: O (se ideEmpregador/tpInsc = [1] e tpLocal = [1, 3]); OC (nos demais casos)
	If cTpInsc == "1" .And. cTpLocal $ "1/3"
		If Empty( cTpInscAci )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0054 + ": " + STR0006 ) //Acidente: XXX / Tipo de Inscri��o do Local do Acidente: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( cTpInscAci $ "1/3/4" )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0054 + ": " + cTpInscAci ) //Acidente: XXX / Tipo de Inscri��o do Local do Acidente: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0055 ) //Valida��o: Deve ser igual a 1- CNPJ, 3- CAEPF ou 4- CNO
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <nrInsc> - n�mero de inscri��o do estabelecimento, de acordo com o tipo de inscri��o indicado no campo ideLocalAcid/tpInsc
	//Valida��o: Deve ser compat�vel com o conte�do do campo ideLocalAcid/tpInsc. Deve ser um identificador v�lido, constante das bases da RFB, e:
	//a) Se tpLocal = [1], deve ser v�lido e existente na Tabela de Estabelecimentos (S-1005); b) Se tpLocal = [3], deve ser diferente dos
	//estabelecimentos informados na Tabela S-1005 e, se ideLocalAcid/tpInsc = [1], diferente do CNPJ base indicado em S-1000.
	//O (se ideEmpregador/tpInsc = [1] e tpLocal = [1, 3]); OC (nos demais casos)
	If cTpInsc == "1" .And. cTpLocal $ "1/3" .And. !Empty( cTpInscAci )
		If Empty( cNrInscAci )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0056 + ": " + STR0006 ) //Acidente: XXX / Inscri��o do Local do Acidente: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !MDTNrInsc( cTpLocal, cTpInscAci, cNrInscAci, cNumMat )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0056 + ": " + cNrInscAci ) //Acidente: XXX / Inscri��o do Local do Acidente: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0057 ) //Valida��o: 1) Deve constar na tabela S-1005 se o local do acidente for igual a 'Estabelecimento do Empregador no Brasil'.
			aAdd( aIncEnv, STR0058 ) //2) Deve ser diferente dos estabelecimentos informados na Tabela S-1005 se o local do acidente for igual a 'Estabelecimento de
			aAdd( aIncEnv, STR0059 ) //Terceiros' e diferente do CNPJ base indicado em S-1000 se o tipo de inscri��o do local do acidente for igual a CNPJ.
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o das tags <codParteAting> - C�digo da parte atingida e <lateralidade> - Lateralidade da(s) parte(s) atingida(s).
	//<codParteAting> Valida��o: Deve ser um c�digo v�lido e existente na Tabela 13.
	//<lateralidade> Valores v�lidos: 0 - N�o aplic�vel, 1 - Esquerda, 2 - Direita ou 3 - Ambas
	//Informa��o obrigat�ria.
	If Len( aParte ) > 0
		For nCont := 1 To Len( aParte )
			If Empty( aParte[ nCont, 1 ] )
				aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0060 + ": " + STR0006 ) //Acidente: XXX / Parte do Corpo Atingida: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !ExistCPO( "C8I", aParte[ nCont, 1 ], 2 )
				aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0060 + ": " + aParte[ nCont, 1 ] ) //Acidente: XXX / Parte do Corpo Atingida: XXX
				aAdd( aIncEnv, STR0007 + ": " + STR0061 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 13 do eSocial
				aAdd( aIncEnv, '' )
			EndIf
			If Empty( aParte[ nCont, 2 ] )
				aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0062 + ": " + STR0006 ) //Acidente: XXX / Lateralidade da Parte Atingida: Em branco
				aAdd( aIncEnv, '' )
			EndIf
		Next nCont
	Else
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0063 ) //Acidente: XXX / N�o existem partes atingidas relacionadas ao acidente
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <codAgntCausador> - C�digo correspondente ao agente causador do acidente.
	//Valida��o: Deve ser um c�digo v�lido e existente na Tabela 14 ou na Tabela 15.
	//Informa��o obrigat�ria.
	If Len( aCausa ) > 0
		For nCont := 1 To Len( aCausa )
			If Empty( aCausa[ nCont, 1 ] )
				aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0064 + ": " + STR0006 ) //Acidente: XXX / Agente Causador do Acidente: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !ExistCPO( "C8J", aCausa[ nCont, 1 ], 2 ) .And. !ExistCPO( "C8K", aCausa[ nCont, 1 ], 2 )
				aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0064 + ": " + aCausa[ nCont, 1 ] ) //Acidente: XXX / Agente Causador do Acidente: XXX
				aAdd( aIncEnv, STR0007 + ": " + STR0065 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 14 ou 15 do eSocial
				aAdd( aIncEnv, '' )
			EndIf
		Next nCont
	Else
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0066 ) //Acidente: XXX / N�o existem agentes causadores relacionados ao acidente
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <dtAtendimento> - Data do atendimento.
	//Valida��o: Deve ser uma data igual ou posterior � data do acidente e igual ou anterior � data atual.
	If Len( aInfAten ) > 0 //Caso existam informa��es de atendimento
		If Empty( dDtAtendimento )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0067 + ": " + STR0006 ) //Acidente: XXX / Data do Atendimento: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( dDtAtendimento >= dDtAcid .And. dDtAtendimento <= dDataBase )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0067 + ": " + DToC( dDtAtendimento ) ) //Acidente: XXX / Data do Atendimento: XX/XX/XXXX
			aAdd( aIncEnv, STR0007 + ": " + STR0017 + ":" ) //Valida��o: Deve ser uma data v�lida e:
			aAdd( aIncEnv, "* " + STR0032 + ": " + DToC( dDtAcid ) ) //* Igual ou posterior � data do acidente: XX/XX/XXXX
			aAdd( aIncEnv, "* " + STR0018 + ": " + DToC( dDataBase ) ) //* Igual ou anterior � data atual: XX/XX/XXXX
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <hrAtendimento> - Hora do atendimento.
	//Valida��o: Deve estar no intervalo entre [0000] e [2359], criticando inclusive a segunda parte do n�mero, que indica os minutos, que deve ser
	//menor ou igual a 59.
	If Len( aInfAten ) > 0 //Caso existam informa��es de atendimento
		If Empty( cHrAtendimento )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0069 + ": " + STR0006 ) //Acidente: XXX / Hora do Atendimento: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <indInternacao> - Indicativo de interna��o.
	//Valores v�lidos: S - Sim ou N - N�o
	If Len( aInfAten ) > 0 //Caso existam informa��es de atendimento
		If Empty( cIndInternacao )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0070 + ": " + STR0006 ) //Acidente: XXX / Indicativo de Interna��o: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( cIndInternacao $ "S/N" )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0070 + ": " + cIndInternacao ) //Acidente: XXX / Indicativo de Interna��o: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0028 ) //Valida��o: Deve ser igual a S- Sim ou N- N�o
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <durTrat> - Dura��o estimada do tratamento, em dias.
	//Caso os campos referentes a dura��o do tratamento (TMT_QTAFAS, TNY_QTDTRA ou TNC_QTAFAS) estiverem preenchidos, envia o conte�do deles,
	//sen�o envia a quantidade de dias como '0'

	//Valida��o da tag <indAfast> - Indicativo de afastamento do trabalho durante o tratamento.
	//Valores v�lidos: S - Sim ou N - N�o. Valida��o: Se o campo indCatObito for igual a [S], o campo deve sempre ser preenchido com [N].
	If Len( aInfAten ) > 0 //Caso existam informa��es de atendimento
		If Empty( cIndAfast )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0071 + ": " + STR0006 ) //Acidente: XXX / Indicativo de Afastamento: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( cIndAfast $ "S/N" )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0071 + ": " + cIndAfast ) //Acidente: XXX / Indicativo de Afastamento: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0028 ) //Valida��o: Deve ser igual a S- Sim ou N- N�o
			aAdd( aIncEnv, '' )
		ElseIf cIndCatObito == "S" .And. !( cIndAfast == "N" )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0071 + ": " + cIndAfast ) //Acidente: XXX / Indicativo de Afastamento: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0072 ) //Valida��o: Se o campo 'Houve Morte' for igual a 'Sim', o indicativo de 'Afastamento' deve ser igual a 'N�o'
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <dscLesao> - Descri��o da natureza da les�o.
	//Valida��o: Deve ser um c�digo v�lido e existente na Tabela 17.
	If Len( aInfAten ) > 0 //Caso existam informa��es de atendimento
		If Empty( cDscLesao )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0073 + ": " + STR0006 ) //Acidente: XXX / C�digo de Descri��o da Natureza da Les�o: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !ExistCPO( "C8M", cDscLesao, 2 )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0073 + ": " + cDscLesao ) //Acidente: XXX / C�digo de Descri��o da Natureza da Les�o: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0074 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 17 do eSocial
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <dscCompLesao> - Descri��o complementar da les�o.
	//N�o possui nenhuma valida��o espec�fica

	//Valida��o da tag <diagProvavel> - Diagn�stico prov�vel.
	//N�o possui nenhuma valida��o espec�fica

	//Valida��o da tag <codCID> - C�digo da tabela de Classifica��o Internacional de Doen�as - CID.
	//Valida��o: Deve ser preenchido com caracteres alfanum�ricos, conforme op��es constantes na tabela CID.
	If Len( aInfAten ) > 0 //Caso existam informa��es de atendimento
		If Empty( cCodCID )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0075 + ": " + STR0006 ) //Acidente: XXX / CID: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <observacao> - Observa��o.
	//N�o possui nenhuma valida��o espec�fica

	//Valida��o da tag <nmEmit> - Nome do m�dico/dentista que emitiu o atestado.
	//Informa��o obrigat�ria
	If Len( aInfAten ) > 0 //Caso existam informa��es de atendimento
		If Empty( cNmEmit )
			aAdd( aIncEnv, cStrFil + " / " + cStrEmi + " / " + STR0076 + ": " + STR0006 ) //Emitente: XXX - XXXXX / Nome: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <ideOC> - �rg�o de classe.
	//Valores v�lidos: 1 - Conselho Regional de Medicina - CRM, 2 - Conselho Regional de Odontologia - CRO ou 3 - Registro do Minist�rio da Sa�de - RMS
	If Len( aInfAten ) > 0 //Caso existam informa��es de atendimento
		If Empty( cIdeOC )
			aAdd( aIncEnv, cStrFil + " / " + cStrEmi + " / " + STR0077 + ": " + STR0006 ) //Emitente: XXX - XXXXX / �rg�o de Classe: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( cIdeOC $ "1/2/3" )
			aAdd( aIncEnv, cStrFil + " / " + cStrEmi + " / " + STR0077 + ": " + cIdeOC ) //Emitente: XXX - XXXXX / �rg�o de Classe: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0078 ) //Valida��o: Deve ser igual a 1- CRM, 2- CRO ou 3- RMS
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <nrOC> - N�mero de inscri��o no �rg�o de classe.
	//Informa��o obrigat�ria
	If Len( aInfAten ) > 0 //Caso existam informa��es de atendimento
		If Empty( cNrOC )
			aAdd( aIncEnv, cStrFil + " / " + cStrEmi + " / " + STR0079 + ": " + STR0006 ) //Emitente: XXX - XXXXX / N�mero de Inscri��o do �rg�o de Classe: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <ufOC> - UF do �rg�o de classe.
	//Valores v�lidos: AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO
	//Preenchimento obrigat�rio se ideOC = [1, 2].
	If Len( aInfAten ) > 0 //Caso existam informa��es de atendimento
		If ( cIdeOC == "1" .Or. cIdeOC == "2" ) .And. Empty( cUfOC )
			aAdd( aIncEnv, cStrFil + " / " + cStrEmi + " / " + STR0080 + ": " + STR0006 ) //Emitente: XXX - XXXXX / UF do �rg�o de Classe: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	Help := .F. //Ativa novamente as mensagens de Help

	cFilAnt := cFilBkp //Retorna filial do registro
	RestArea( aArea ) //Retorna �rea

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTCATOrig
Verifica se a CAT atual possui CAT Origem e retorna as o recibo pela
vari�vel private cNrRecCatOrig, al�m de inicializar as vari�veis
dDtAcid e cHrAcid para envio do evento S-2210 ao SIGATAF/Middleware

@sample	MDTCATOrig( "2", 13/10/2021, "23:59" )

@param	cTipoCAT, Caracter, Indica o tipo da CAT para que ser� buscada a CAT origem
@param	dDtCAT, Data, Indica a data da CAT para que ser� buscada a CAT origem
@param	cHrCAT, Caracter, Indica a hora da CAT para que ser� buscada a CAT origem

@author	Luis Fellipy Bett
@since	14/04/2020
/*/
//-------------------------------------------------------------------
Function MDTCATOrig( cTipoCAT, dDtCAT, cHrCAT )

	//Salva as �reas
	Local aArea := GetArea()
	Local aAreaTNC := TNC->( GetArea() ) //Guarda a �rea do registro atual da TNC
	
	//Vari�veis de busca das informa��es
	Local aEvento   := {}
	Local cIdFunc	:= ""
	Local nEvento   := 0

	//Vari�veis de chamadas
	Local lMDTA883 := IsInCallStack( "MDTA883" )

	//Caso seja CAT de Reabertura ou Comunica��o de �bito, a data e n�mero da CAT Origem estiverem
	//preenchidos e a data da CAT Origem for maior que a data de in�cio da obrigatoriedade do eSocial
	If cTipoCAT $ "2/3"

		//Caso envio seja atrav�s do SIGATAF
		If !lMiddleware

			//Busca o ID do funcion�rio
			cIdFunc := MDTGetIdFun( cNumMat )

			//Posiciona na CM0 para buscar as CAT's de mesma data e hora
			dbSelectArea( "CM0" )
			dbSetOrder( 4 )
			If dbSeek( xFilial( "CM0" ) + cIdFunc + DToS( dDtCAT ) + StrTran( cHrCAT, ":", "" ) )

				While CM0->( !Eof() ) .And. CM0->CM0_FILIAL == xFilial( "CM0" ) .And. CM0->CM0_TRABAL == cIdFunc .And. ;
					DToS( CM0->CM0_DTACID ) == DToS( dDtCAT ) .And. StrTran( CM0->CM0_HRACID, ":", "" ) == StrTran( cHrCAT, ":", "" ) .And. ;
					CM0->CM0_TPCAT != cTipoCAT

					//Salva o recibo da CAT origem
					cNrRecCatOrig := AllTrim( CM0->CM0_PROTUL )

					//Pula o registro para verificar se existe um pr�ximo
					CM0->( dbSkip() )

				End

			EndIf

		Else

			//Busca os Xml's do evento S-2210 para o funcion�rio
			aEvento := MDTLstXml( "S2210", cNumMat )

			//Verifica entre os Xml's encontrados qual se refere a CAT Origem
			For nEvento := 1 To Len( aEvento )

				//Verifica se o xml atual se refere a CAT cadastrada
				If ( MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:dtAcid", "D" ) == dDtCAT ) .And.;
				( MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:hrAcid", "C" ) == StrTran( cHrCAT, ":", "" ) ) .And.;
				( MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:tpCat", "C" ) != cTipoCAT )

					cNrRecCatOrig := AllTrim( aEvento[ nEvento, 2 ] ) // Salva o recibo da CAT origem

					Exit

				EndIf

			Next nEvento

		EndIf

	EndIf

	//Caso n�o for chamado pela rotina de sincroniza��o das informa��es da CAT
	If !lMDTA883

		//Caso n�o tenha CAT Origem, pega a data e hor�rio da CAT Atual
		dDtAcid := dDtCAT
		cHrAcid := StrTran( cHrCAT, ":", "" )

	EndIf

	//Retorna as �rea
	RestArea( aAreaTNC ) //Retorna �rea para o registro correto da TNC
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTInfAte
Busca as informa��es do emitente do atestado quando cadastro de acidente

@sample	MDTInfAte()

@return	aInfo, Array, Array contendo as informa��es do atendimento m�dico do acidente

@author	Luis Fellipy Bett
@since	17/02/2021
/*/
//-------------------------------------------------------------------
Function MDTInfAte()

	//Vari�veis para busca das informa��es
	Local aInfo		:= {} //Guarda as informa��es no array para retorno
	Local cMaisRec	:= "" //Vari�vel de verifica��o do registro de diagn�stico/atestado mais recente
	Local cAcidente	:= M->TNC_ACIDEN
	Local cNumFic	:= M->TNC_NUMFIC
	Local cDtAcid	:= M->TNC_DTACID
	Local cHrAcid	:= M->TNC_HRACID
	Local cTipoCAT	:= M->TNC_TIPCAT

	//Caso for uma CAT de reabertura ou �bito, busca o acidente inicial
	If cTipoCAT $ "2/3"

		//Busca a CAT inicial
		cAcidente := MDTCatIni( cNumFic, cDtAcid, cHrAcid )

	EndIf

	//--------------------------------------------------------------
	// Verifica se as informa��es do atendimento ser�o consideradas
	// do Diagn�stico, Atestado ou o mais recente deles
	//--------------------------------------------------------------
	If cAtendAci == "1" //Caso deva ser considerado o Diagn�stico

		aInfo := fGetDiagn( cAcidente )

	ElseIf cAtendAci == "2" //Caso deva ser considerado o Atestado

		aInfo := fGetAtest( cAcidente )

	ElseIf cAtendAci == "3" //Caso deva ser considerado o mais recente entre Diagn�stico e Atestado

		cMaisRec := fVerMaisRec( cAcidente ) //Verifica se o atestado ou o diagn�stico � o mais recente

		If cMaisRec == "1" //Se o mais atual for o Diagn�stico

			aInfo := fGetDiagn( cAcidente )

		ElseIf cMaisRec == "2" //Se o mais atual for o Atestado

			aInfo := fGetAtest( cAcidente )

		EndIf

	EndIf

	//Caso exista um diagn�stico/atestado vinculado ao acidente
	If Len( aInfo ) > 0
		//Trata o campo para os valores padr�es do eSocial
		If "CRM" $ aInfo[ 9 ]
			aInfo[ 9 ] := "1"
		ElseIf "CRO" $ aInfo[ 9 ]
			aInfo[ 9 ] := "2"
		ElseIf "RMS" $ aInfo[ 9 ]
			aInfo[ 9 ] := "3"
		EndIf
	EndIf

	//Caso o atendimento tenha sido definido no acidente, troca as informa��es do atendimento do diagn�stico/atestado pelas do acidente
	If lAtesAcid
		If Len( aInfo ) > 0 //Caso exista um diagn�stico/atestado vinculado ao acidente
			aInfo[ 1 ] := M->TNC_DTATEN //Pega a data de atendimento definida no acidente
			aInfo[ 2 ] := StrTran( M->TNC_HRATEN, ":", "" ) //Pega a hora de atendimento definida no acidente
			aInfo[ 3 ] := cValToChar( M->TNC_QTAFAS ) //Pega a dura��o do tratamento definida no acidente
			aInfo[ 4 ] := IIf( M->TNC_AFASTA == "1", "S", "N" ) //Pega o indicativo de afastamento relacionado ao acidente
			aInfo[ 5 ] := AllTrim( StrTran( M->TNC_CID, ".", "" ) ) //Pega o CID relacionado ao acidente
		Else
			aAdd( aInfo, M->TNC_DTATEN ) //Pega a data de atendimento definida no acidente
			aAdd( aInfo, StrTran( M->TNC_HRATEN, ":", "" ) ) //Pega a hora de atendimento definida no acidente
			aAdd( aInfo, cValToChar( M->TNC_QTAFAS ) ) //Pega a dura��o do tratamento definida no acidente
			aAdd( aInfo, IIf( M->TNC_AFASTA == "1", "S", "N" ) ) //Pega o indicativo de afastamento relacionado ao acidente
			aAdd( aInfo, AllTrim( StrTran( M->TNC_CID, ".", "" ) ) ) //Pega o CID relacionado ao acidente
		EndIf
	EndIf

Return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetDiagn
Busca as informa��es do Diagn�stico

@sample	fGetDiagn()

@return	aInfo, Array, Array com as informa��es do Diagn�stico

@author	Luis Fellipy Bett
@since	11/03/2021
/*/
//-------------------------------------------------------------------
Static Function fGetDiagn( cAcidente )

	Local aArea	 := GetArea() //Pega a �rea
	Local aInfo	 := {}
	Local lAchou := .T.
	Local lExclu := IIf( IsInCallStack( "MDTR832" ), .F., !( INCLUI .Or. ALTERA ) ) //Verifica se � exclus�o

	If !lDiagnostico
		dbSelectArea( "TMT" )
		dbSetOrder( 7 )
		If dbSeek( xFilial( "TMT" ) + cAcidente )
			RegToMemory( "TMT", .F., , .F. )
		Else
			lAchou := .F. //Define como .F. para n�o salvar as informa��es no array
		EndIf
	EndIf

	If lAchou .And. ( IsInCallStack( "MDTR832" ) .Or. !( lDiagnostico .And. lExclu ) ) //Caso ache o registro e n�o for exclus�o de diagn�stico
		//Adiciona ao array de retorno as informa��es do diagn�stico
		aAdd( aInfo, M->TMT_DTATEN )
		aAdd( aInfo, StrTran( M->TMT_HRATEN, ":", "" ) )
		aAdd( aInfo, IIf( !Empty( M->TMT_QTAFAS ), AllTrim( cValToChar( M->TMT_QTAFAS ) ), "0" ) )
		aAdd( aInfo, IIf( M->TMT_QTAFAS > 0, "S", "N" ) )
		aAdd( aInfo, AllTrim( StrTran( M->TMT_CID, ".", "" ) ) )
		aAdd( aInfo, AllTrim( MDTSubTxt( Upper( fGetDesDia() ) ) ) )
		aAdd( aInfo, Alltrim( MDTSubTxt( Upper( M->TMT_OUTROS ) ) ) )
		aAdd( aInfo, Posicione( "TMK", 1, xFilial( "TMK" ) + M->TMT_CODUSU, "TMK_NOMUSU" ) )
		aAdd( aInfo, Posicione( "TMK", 1, xFilial( "TMK" ) + M->TMT_CODUSU, "TMK_ENTCLA" ) )
		aAdd( aInfo, AllTrim( Posicione( "TMK", 1, xFilial( "TMK" ) + M->TMT_CODUSU, "TMK_NUMENT" ) ) )
		aAdd( aInfo, Posicione( "TMK", 1, xFilial( "TMK" ) + M->TMT_CODUSU, "TMK_UF" ) )
		aAdd( aInfo, M->TMT_CODUSU )
	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetAtest
Busca as informa��es do Atestado

@sample	fGetAtest()

@return	aInfo, Array, Array com as informa��es do Atestado

@author	Luis Fellipy Bett
@since	11/03/2021
/*/
//-------------------------------------------------------------------
Static Function fGetAtest( cAcidente )

	Local aArea	 := GetArea() //Pega a �rea
	Local aInfo	 := {}
	Local lAchou := .T.
	Local lExclu := IIf( IsInCallStack( "MDTR832" ), .F., !( INCLUI .Or. ALTERA ) ) //Verifica se � exclus�o

	If !lAtestado
		dbSelectArea( "TNY" )
		dbSetOrder( 5 )
		If dbSeek( xFilial( "TNY" ) + cAcidente )
			RegToMemory( "TNY", .F., , .F. )
		Else
			lAchou := .F. //Define como .F. para n�o salvar as informa��es no array
		EndIf
	EndIf

	If lAchou .And. ( IsInCallStack( "MDTR832" ) .Or. !( lAtestado .And. lExclu ) ) //Caso ache o registro e n�o for exclus�o de atestado
		//Adiciona no array de retorno as informa��es do atestado
		aAdd( aInfo, M->TNY_DTCONS )
		aAdd( aInfo, StrTran( M->TNY_HRCONS, ":", "" ) )
		aAdd( aInfo, IIf( !Empty( !Empty( M->TNY_QTDTRA ) ), AllTrim( M->TNY_QTDTRA ), "0" ) )
		aAdd( aInfo, IIf( !Empty( M->TNY_CODAFA ), "S", "N" ) )
		aAdd( aInfo, AllTrim( StrTran( M->TNY_CID, ".", "" ) ) )
		aAdd( aInfo, AllTrim( MDTSubTxt( Upper( fGetDesDia() ) ) ) )
		aAdd( aInfo, Alltrim( MDTSubTxt( Upper( Posicione( "TMT", 7, xFilial( "TMT" ) + M->TNY_ACIDEN + M->TNY_NUMFIC, "TMT_OUTROS" ) ) ) ) )
		aAdd( aInfo, Posicione( "TNP", 1, xFilial( "TNP" ) + M->TNY_EMITEN, "TNP_NOME" ) )
		aAdd( aInfo, Posicione( "TNP", 1, xFilial( "TNP" ) + M->TNY_EMITEN, "TNP_ENTCLA" ) )
		aAdd( aInfo, AllTrim( Posicione( "TNP", 1, xFilial( "TNP" ) + M->TNY_EMITEN, "TNP_NUMENT" ) ) )
		aAdd( aInfo, Posicione( "TNP", 1, xFilial( "TNP" ) + M->TNY_EMITEN, "TNP_UF" ) )
		aAdd( aInfo, M->TNY_EMITEN )
	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} fVerMaisRec
Verifica qual o registro de diagn�stico/atestado mais recente vinculado ao acidente

@sample	fVerMaisRec()

@return	cRet, Caracter, "1" caso Diagn�stico mais recente, "2" caso atestado e "0" se n�o existir nenhum atestado/diagn�stico vinculado

@author	Luis Fellipy Bett
@since	11/03/2021
/*/
//-------------------------------------------------------------------
Static Function fVerMaisRec( cAcidente )

	Local cRet	  := "0" //Define por padr�o 0 para caso n�o encontrar nenhum diagn�stico/atestado
	Local dDtDiag := SToD( "" )
	Local dDtAtes := SToD( "" )
	Local lExclu  := IIf( IsInCallStack( "MDTR832" ), .F., !( INCLUI .Or. ALTERA ) ) //Verifica se � exclus�o

	//Busca a data do atendimento do Diagn�stico
	If lDiagnostico
		dDtDiag := IIf( lExclu, SToD( "" ), M->TMT_DTATEN ) //Caso for exclus�o do diagn�stico, pega a data como vazia
	Else
		dDtDiag := Posicione( "TMT", 7, xFilial( "TMT" ) + cAcidente, "TMT_DTATEN" )
	EndIf

	//Busca a data do atendimento do Atestado
	If lAtestado
		dDtAtes := IIf( lExclu, SToD( "" ), M->TNY_DTCONS ) //Caso for exclus�o do atestado, pega a data como vazia
	Else
		dDtAtes := Posicione( "TNY", 5, xFilial( "TNY" ) + cAcidente, "TNY_DTCONS" )
	EndIf

	//Avalia o documento mais recente
	If !Empty( dDtDiag ) .And. Empty( dDtAtes ) //Caso s� exista um atestado cadastrado
		cRet := "1"
	ElseIf Empty( dDtDiag ) .And. !Empty( dDtAtes ) //Caso s� exista um diagn�stico cadastrado
		cRet := "2"
	ElseIf !Empty( dDtDiag ) .And. !Empty( dDtAtes ) //Caso exista os dois, verifica qual o mais atual
		If dDtDiag >= dDtAtes
			cRet := "1"
		Else
			cRet := "2"
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetDesDia
Busca as informa��es do diagn�stico m�dico (TMT_MDIAGN), quando
chamado pelo acidente ou pelo atestado m�dico

@sample	fGetDesDia()

@return	cRet, Caracter, Informa��o do diagn�stico a ser retornada

@author	Luis Fellipy Bett
@since	10/03/2021
/*/
//-------------------------------------------------------------------
Static Function fGetDesDia( nOpc )

	Local aArea := GetArea() //Guarda a �rea
	Local cRet := ""

	If aArea[ 1 ] <> "TMT"
		dbSelectArea( "TMT" )
		dbSetOrder( 7 )
		dbSeek( xFilial( "TMT" ) + IIf( lAtestado, M->TNY_ACIDEN + M->TNY_NUMFIC, TNY->TNY_ACIDEN + TNY->TNY_NUMFIC ) )
		RegToMemory( "TMT", .F., , .F. ) //Adiciona os registros da TMT a mem�ria para pegar o c�digo da SYP
	EndIf

	//Busca a descri��o do campo de acordo com o c�digo da SYP
	cRet := NgMemo( M->TMT_DIASYP )

	//Retorna a �rea
	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTGetTKEY
Busca a TAFKEY do acidente na tabela TAFXERP do TAF

@sample	MDTGetTKEY()

@return	cKey, Caracter, TAFKEY do registro do acidente

@param	cChave, Caracter, Chave atual do registro no TAF

@author	Luis Fellipy Bett
@since	27/10/2021
/*/
//-------------------------------------------------------------------
Function MDTGetTKEY( cChave )

	Local aArea		:= GetArea() //Salva a �rea
	Local cAliasTAF	:= ""
	Local cKey		:= ""
	Local cIdFunc	:= ""
	Local nRecnoCM0 := 0

	//Busca o ID do funcion�rio
	cIdFunc := MDTGetIdFun( cNumMat )

	dbSelectArea( "CM0" )
	dbSetOrder( 4 ) //CM0_FILIAL + CM0_TRABAL + DTOS(CM0_DTACID) + CM0_HRACID + CM0_TPCAT + CM0_ATIVO
	If dbSeek( xFilial( "CM0" ) + cIdFunc + cChave )
		
		//Caso exista o campo referente ao TAFKEY na CM0 e esteja preenchido
		If CM0->( ColumnPos( "CM0_TAFKEY" ) ) > 0 .And. !Empty( CM0->CM0_TAFKEY )

			cKey := AllTrim( CM0->CM0_TAFKEY )

		Else //Caso o campo n�o existir, continua pegando o Recno para buscar pela TAFXERP
		
			nRecnoCM0 := CM0->( Recno() )

		EndIf

	EndIf

	//Caso o registro exista na CM0, busca o TAFKEY na tabela TAFXERP
	If nRecnoCM0 > 0

		//Pega o alias para montar a query
		cAliasTAF := GetNextAlias()

		//Monta a query para busca do TAFKEY
		BeginSQL Alias cAliasTAF
			SELECT TAFKEY
				FROM TAFXERP
					WHERE TAFALIAS = 'CM0'
						AND TAFRECNO = %Exp:nRecnoCM0%
						AND TAFXERP.%NotDel%
		EndSQL

		//Posiciona no registro encontrado para pegar o TAFKEY
		dbSelectArea( cAliasTAF )

		//Pega a TAFKEY do registro
		cKey := AllTrim( ( cAliasTAF )->TAFKEY )

		//Fecha a tabela tempor�ria
		( cAliasTAF )->( dbCloseArea() )

	EndIf

	//Retrona a �rea
	RestArea( aArea )

Return cKey

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTCatIni
Busca o acidente inicial em casos de CAT de reabertura ou �bito para
buscar corretamente as informa��es do atestado/diagn�stico

@sample	MDTCatIni()

@return	cKey, Caracter, TAFKEY do registro do acidente

@param	cChave, Caracter, Chave atual do registro
@param	cChvNov, Caracter, Chave nova do registro

@author	Luis Fellipy Bett
@since	27/10/2021
/*/
//-------------------------------------------------------------------
Function MDTCatIni( cNumFic, cDtAcid, cHrAcid )

	//Salva as �reas
	Local aArea := GetArea()
	Local aAreaTNC := TNC->( GetArea() )

	//Vari�veis para busca das informa��es
	Local cAcidente := ""

	//Vari�veis de tabelas tempor�rias
	Local cAliasTNC := GetNextAlias() //Pega o pr�ximo alias

	BeginSQL Alias cAliasTNC

		SELECT
			TNC.TNC_ACIDEN
		FROM
			%Table:TNC% TNC
		WHERE
			TNC.TNC_FILIAL = %xFilial:TNC% AND
			TNC.TNC_NUMFIC = %Exp:cNumFic% AND
			TNC.TNC_DTACID = %Exp:cDtAcid% AND
			TNC.TNC_HRACID = %Exp:cHrAcid% AND
			TNC.TNC_TIPCAT = '1' AND
			TNC.%NotDel%

	EndSQL

	//Posiciona na tabela para pegar o acidente inicial
	dbSelectArea( cAliasTNC )
	( cAliasTNC )->( dbGoTop() )

	//Pega o c�digo do acidente inicial
	cAcidente := ( cAliasTNC )->TNC_ACIDEN

	//Fecha a tabela tempor�ria
	( cAliasTNC )->( dbCloseArea() )

	//Retorna as �reas
	RestArea( aAreaTNC )
	RestArea( aArea )

Return cAcidente
