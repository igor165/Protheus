#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PONRELOBJ

@author		Igor Franzoi
@since		04/08/2010
@version	1.0
@return		NIL
@obs		Controle dos campos do SP0 - Relógio de Ponto
/*/
//-------------------------------------------------------------------
class PONRELOBJ

	data cFilSP0	//Filial do Relogio
	data cCodREP	//Codigo do REP
	data cEmpREP	//Codigo da Empresa
	data cIprREP	//Endereco IP do relógio
	data cHASH		//Codigo HASH
	data cArquivo	//Arquivo do Relogio	
	data cNovoRel	//Novo relogio	

	data nPorREP	//Porta de enderecamento do Relogio
	data nDiaIni	//Posicao inicial do Dia
	data nDiaFim	//Qtde de posicoes do Dia
	data nMesIni	//Posicao inicial do Mes
	data nMesFim	//Qtde de posicoes do Mes
	data nAnoIni	//Posicao inicial do Ano
	data nAnoFim	//Qtde de posicoes do Ano	
	data nHrsIni	//Posicao inicial da Hora	
	data nHrsFim	//Qtde de posicoes da Horao
	data nMinIni	//Posicao inicial dos Minutos
	data nMinFim	//Qtde de posicoes dos Minutos	
	data nPisIni	//Posicao inicial do PIS	
	data nPisFim	//Qtde de posicoes do PIS
	
	Method New()
	Method setVarMem()
	Method setVarFie()	
	Method pesFun()
	
endclass

//-------------------------------------------------------------------
/*/{Protheus.doc} New()

@author		Igor Franzoi
@since		04/08/2010
@version	1.0
@return		NIL
@obs		Controle dos campos do SP0 - Relógio de Ponto
/*/
//-------------------------------------------------------------------
Method New() class PONRELOBJ

	::cCodREP	:= Space( GetSx3Cache( "P0_REP" 	, "X3_TAMANHO" ) )	//Codigo do REP
	::cEmpREP	:= cEmpAnt 												//Codigo da Empresa
	::cIprREP	:= Space( GetSx3Cache( "RFL_ENDIP" 	, "X3_TAMANHO" ) ) //Endereco IP do relógio        	
	::nPorREP	:= Space( GetSx3Cache( "RFL_PORTA" 	, "X3_TAMANHO" ) ) //Porta de enderecamento do Relogio
	::cArquivo	:= Space( GetSx3Cache( "P0_ARQUIVO"	, "X3_TAMANHO" ) )	//Arquivo do Relogio
	::cHASH	:= Space( GetSx3Cache( "RFL_HASH" 	, "X3_TAMANHO" ) ) //
	
Return (Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} setVarMem()

@author		Igor Franzoi
@since		04/08/2010
@version	1.0
@return		NIL
@obs		Seta os valores das variaveis, com valores de memoria do SP0
/*/
//-------------------------------------------------------------------
Method setVarMem() class PONRELOBJ

	::cFilSP0	:= 	M->P0_FILIAL	//Filial do Relogio
	::cEmpREP	:= 	SM0->M0_CGC		//Codigo da Empresa
	::cCodREP	:= 	M->P0_REP		//Codigo do REP
	::cArquivo	:=  M->P0_ARQUIVO	//Arquivo do Relogio
	//::cIprREP	:=  //Endereco IP do relógio
	//::nPorREP	:=  //Porta de enderecamento do Relogio
	//::cHASH		:=  //
	
Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} setVarFie()

@author		Igor Franzoi
@since		04/08/2010
@version	1.0
@return		NIL
@obs		Controle dos campos do SP0 - Relógio de Ponto
/*/
//-------------------------------------------------------------------
Method setVarFie() class PONRELOBJ

	Local lRet := .F.

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Garante que o alias SP0 esta selecionado					  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	If ( Select( "SP0" ) > 0 )

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Garante que nao esta no fim do arquivo para carregar as var. ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		If ( SP0->(!Eof()) )

			If !Empty( SP0->P0_REP )
			
				::cFilSP0	:= 	SP0->P0_FILIAL	//Filial do Relogio
				::cCodREP	:= 	SP0->P0_REP		//Codigo do REP
				::cEmpREP	:=  SM0->M0_CGC		//Codigo da Empresa
				::cArquivo	:=  SP0->P0_ARQUIVO	//Arquivo do Relogio
				::cNovoRel	:=  SP0->P0_NOVO	//Novo relogio
				//::cIprREP	:=  //Endereco IP do relógio        	
				//::nPorREP	:=  //Porta de enderecamento do Relogio
				//::cHASH		:=  //Hash
	
			    //Variaveis das posicoes do layout do txt de marcacoes
				::nDiaIni	:= 11				//Posicao inicial do Dia
				::nDiaFim	:= 2				//Qtde de posicoes do Dia
				::nMesIni 	:= 13				//Posicao inicial do Mes
				::nMesFim	:= 2				//Qtde de posicoes do Mes
				::nAnoIni	:= 15				//Posicao inicial do Ano
				::nAnoFim	:= 4				//Qtde de posicoes do Ano
				::nHrsIni	:= 19				//Posicao inicial da Hora
				::nHrsFim	:= 2				//Qtde de posicoes da Hora
				::nMinIni	:= 21				//Posicao inicial dos Minutos
				::nMinFim	:= 2				//Qtde de posicoes dos Minutos
				::nPisIni 	:= 23				//Posicao inicial do PIS
				::nPisFim 	:= 12				//Qtde de posicoes do PIS

				lRet := .T.
				
			EndIf
						
		EndIf
	
	EndIf
	
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} pesFun()

@author		Allyson Mesashi
@since		12/08/2010
@version	1.0
@return		NIL
@obs		Pesquisa a data de admissao do funcionario
/*/
//-------------------------------------------------------------------
Method pesFun(cPIS) class PONRELOBJ

	Local aArea			:= GetArea()
	Local aDatasAdm		:= {}
	
	Local cAlias   		:= "SRA"
	Local cAliQry		:= ""
	
	Local dData			:= cToD("//")
	
	Local lQueryOpened  := .F.
	Local lRet			:= .T.
	
	Default cPis   		:= ""
	
	If !( Select("SRA") > 0 )
		dbSelectArea("SRA")
	EndIf
	
	(cAlias)->( dbSetOrder( RetOrdem("SRA","RA_PIS+RA_FILIAL") ) )
	
	lQueryOpened  := .T.

	cAliQry := GetNextAlias()
	
	cWhrQry := "%"
	cWhrQry += " SRA.RA_PIS = " + "'" + cPIS + "' "
	cWhrQry += "%"	
							
	cFieQry := "%" 
	cFieQry += " SRA.RA_PIS  ,"
	cFieQry += " SRA.RA_FILIAL, "	
	cFieQry += " SRA.RA_ADMISSA "	
	cFieQry += "%"		
					
	cOrdeBy := "% SRA.RA_PIS, SRA.RA_FILIAL %"

	BeginSql alias cAliQry
		SELECT 		%exp:cFieQry%
		FROM 		%table:SRA% SRA
		WHERE 		%exp:cWhrQry% AND
					SRA.%NotDel% 
		ORDER BY    %exp:cOrdeBy%				
	EndSql

	If lRet .And. !lQueryOpened
	
		While (cAlias)->( !Eof() .And. AllTrim(SRA->RA_PIS) == cPIS )
			aAdd(aDatasAdm, SRA->RA_ADMISSA  )		
			(cAlias)->( dbSkip() )
			Loop
		End While
	
	Else
	
		While (cAliQry)->( !Eof() .And. AllTrim(RA_PIS) == cPIS )
			aAdd(aDatasAdm, sToD(RA_ADMISSA)  )		
			(cAliQry)->( dbSkip() )
			Loop
		End While
	
	EndIf
	
	If lQueryOpened
		(cAliQry)-> (dbCloseArea())
	EndIf
	
	dData := aDatasAdm[1]
	
	RestArea(aArea)

Return (dData)
