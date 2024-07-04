#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM008.CH"

Static oStructRHR	// Calculo do Plano de Saude
Static aPerAtual
Static cAliasHist := "RHR"
Static cCompCalc  := ""

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    	Ё GPEM008    Ё Autor Ё Mauricio Takakura            Ё Data Ё 16/10/11     Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё Calculo do Plano de Saude                                               Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEM008()                                                               Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                              Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			    Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC			Ё  Motivo da Alteracao                        Ё╠╠
╠╠цдддддддддддддеддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia Car. Ё15/05/2014Ё00000014938/2014-TPPCSB     ЁIncluido o fonte da 11 para a  Ё╠╠
╠╠Ё             Ё          Ё                            Ё12 e efetuada a limpeza.	    Ё╠╠
╠╠ЁEsther V.    Ё07/04/2015Ё00000009877/2015-TSAZNL     ЁAlterada ModelDef() para nao   Ё╠╠
╠╠Ё             Ё          Ё                            Ёbuscar periodo atual se chamadaЁ╠╠
╠╠Ё             Ё          Ё                            Ёvier do fonte GPEA001.         Ё╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддддддддддддддаддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Static Function ModelDef()

	Local oModel
	Local oStructSRA
	  
    cAliasHist := "RHR"

	If Type("aPerAtual") == "U" .or. Empty(aPerAtual) .or. !(aPerAtual[1,8] == SRA->RA_PROCES)
		fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, IIf(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar()) )	
		If Empty(aPerAtual)
			Help( ,, 'HELP',, OemToAnsi( STR0004 + SRA->RA_PROCES), 1, 0 )
		Else
			cCompCalc := AnoMes(aPerAtual[1,6])
		EndIf
	EndIf
	If Type( "cCompFil" ) <> "U"
		If cCompFil < cCompCalc .AND. !IsInCallStack("FMANUTCALC") //Se perМodo for menor que perМodo atual e nЦo for manutenГЦo (manutenГЦo И apenas no perМodo atual), busca dados do histСrico
			cAliasHist := "RHS"
		Endif
		cCompCalc := cCompFil
	EndIf
	
	// Criacao do Objeto de Modelagem de dados //	
	oModel     := MPFormModel():New("GPEM008",, /*{ |oModel| Gp008PosValid( oModel ) }*/, /*{ |oModel| Gp001Commit(oModel) }*/ )
	oModel:SetDescription( OemToAnsi(STR0001) ) //"Calculo do Plano de Saude" 
    
	// Cabecalho de dados - SRA (Funcionario)//
	oStructSRA := FWFormStruct( 1, "SRA", { |cCampo| GpM008SRAStru( cCampo ) } )
	oModel:AddFields( "GPEM008_MSRA", NIL, oStructSRA )
	oModel:GetModel( "GPEM008_MSRA" ):SetDescription( OemToAnsi( STR0001 ) ) //"Calculo do Plano de Saude" 
	oModel:GetModel( 'GPEM008_MSRA' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'GPEM008_MSRA' ):SetOnlyView( .T. )

	// Estrutura de campos do Model - RHR - Resultado do Calculo
	oStructRHR := FWFormStruct( 1, cAliasHist, { |cCampo| DefStrRHR(cCampo) } )

	// Desabilita a edicao de todos os campos da tabela RHR para depois 
	// habilitar somente os campos Vl do Funcionario e Vl da Empresa para edicao
	oStructRHR:SetProperty( "*"				, MODEL_FIELD_WHEN, { || .F. } )
	oStructRHR:SetProperty( cAliasHist+"_VLRFUN"	, MODEL_FIELD_WHEN, { |oModel| When_NotEdit( oModel ) } )
	oStructRHR:SetProperty( cAliasHist+"_VLREMP"	, MODEL_FIELD_WHEN, { |oModel| When_NotEdit( oModel ) } )

	oModel:AddGrid( "GPEM008_MRHR", "GPEM008_MSRA", oStructRHR,, { |oModel| RHR_LinhaOK( oModel ) }, /*bPre*/, /*bPost*/, {|oGrid| CargaPLA(oGrid, cAliasHist, cCompCalc) } )

	oModel:GetModel( "GPEM008_MRHR" ):SetDescription( OemToAnsi(STR0001) ) //"Calculo do Plano de Saude"

	// Desabilita a inclusao e delecao de linhas da grid para impedir a perda de valores calculados
	oModel:GetModel( "GPEM008_MRHR" ):SetNoInsertLine( .T. )
	oModel:GetModel( "GPEM008_MRHR" ):SetNoDeleteLine( .T. )

	oModel:SetRelation( "GPEM008_MRHR", { { cAliasHist+"_FILIAL", 'xFilial( "SRA" )' }, { cAliasHist+"_MAT", 'SRA->RA_MAT' } }, (cAliasHist)->( IndexKey( 1 ) ) )
	
Return( oModel )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Mauricio TakakuraЁ Data Ё27/09/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM008                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()
	Local oView 
	Local oModel
	Local oStructSRA
	Local oStructRHR

	// Vincular o View ao Model //
	oModel := FWLoadModel("GPEM008")

	// Criacao da Interface //
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Criacao do Cabecalho - SRA (Funcionario) //
	oStructSRA := FWFormStruct(2, "SRA", { |cCampo| GpM008SRAStru( cCampo ) })
	oStructSRA:SetNoFolder()
	oView:AddField("GPEM008_VSRA", oStructSRA, "GPEM008_MSRA" )
	
	// Criacao do Cabecalho - RHR - Resultado do Calculo
	oStructRHR 	:= FWFormStruct( 2, cAliasHist, { |cCampo| DefStrRHR(cCampo) } )
	oStructRHR:RemoveField( cAliasHist+"_MAT" )

	oView:AddGrid("GPEM008_VRHR", oStructRHR, "GPEM008_MRHR" )

	// Desenho da Tela //
	oView:CreateHorizontalBox("SRA_HEAD", 12)
	oView:CreateHorizontalBox(cAliasHist+"_CALC", 88)
	
	oView:SetOwnerView( "GPEM008_VSRA", "SRA_HEAD" )
	oView:SetOwnerView( "GPEM008_VRHR", cAliasHist+"_CALC" )
	
Return oView

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GpM008SRAStru	ЁAutorЁ  Mauricio TakakuraЁ Data Ё31/10/2010Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSelecionar os campos para a estrutura do SRA                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM008                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GpM008SRAStru( cCampo )
	Local lRet := .F.
	
	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_MAT*RA_NOME*RA_ADMISSA' 
		lRet := .T.
	EndIf
	
Return lRet

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё When_NotEdit   ЁAutorЁ TOTVS			  Ё Data Ё18/05/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o Ё Permite somente digitacao em inclusao                      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё < Vide Parametros Formais >								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      Ё GPEM008                                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ < Vide Parametros Formais >								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function When_NotEdit( oStruct )
Local lRet := .F.

If oStruct:GetValue( cAliasHist+"_TPLAN" ) == "1"
	lRet := .T.
Else
	Help( ,, 'HELP',, OemToAnsi( STR0002 + CRLF + STR0003 ), 1, 0 )	// "Somente registros com Tipo de LanГamento igual a Plano podem ser alterados." ### "Registros com Tipo de LanГamento Co-participaГЦo ou Reembolso devem ser alterados em seus lanГamentos originais."
EndIf

Return( lRet )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё RHR_LinhaOK	ЁAutorЁ TOTVS			  Ё Data Ё18/05/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o Ё Pos Valid do Model para alterar campo TIPO de 1-Calculado	Ё
Ё		   Ё para 2-Modificado.											Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё < Vide Parametros Formais >								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      Ё GPEM008                                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function RHR_LinhaOK( oStruct )
Local lRet := .T.

If oStruct:IsUpdated()
	oStruct:LoadValue( cAliasHist+"_TIPO", "2" )
EndIf

Return( lRet )

/*/{Protheus.doc} DefStrRHR
Definicao dos campos a ser utilizado na estrutura GPEM008_MRHR
@author Allyson Luiz Mesashi
@since 08/03/2022
@param  cCampo, caracter, nome do campo a ser validado
@return lRetorno, logico, se campo farА parte ou nЦo da estrutura
/*/
Static Function DefStrRHR(cCampo)

Local lRetorno 	:= .F.
Local nPos		:= At("_", cCampo)

If AllTrim( SubStr(cCampo, nPos ) ) $ '_FILIAL/_MAT/_DATA/_ORIGEM/_CODIGO/_TPLAN/_TPFORN/_CODFOR/_TPPLAN/_PLANO/_PD/_VLRFUN/_VLREMP/_COMPPG/_TIPO/_INTFOL/'
	lRetorno := .T.
EndIf

Return lRetorno

/*/{Protheus.doc} CargaPLA
Carrega registros de cАlculo do plano de saЗde
@author Allyson Luiz Mesashi
@since 08/03/2022
@param oGrid, objeto, grid da estrutura a ser carregada
@param cTab, caracter, alias da tabela de plano de saЗde
@param cPerPLA, caracter, perМodo de cАlculo
@return aRet, array, array com os registros carregados
/*/
Static Function CargaPLA(oGrid, cTab, cPerPLA)

Local aRet	:= {}
Local aArea := (cTab)->( GetArea() )

If (cTab)->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+cPerPLA ) )
	While (cTab)->( !EoF() ) .And. (cTab)->( &(cTab+"_FILIAL") )+(cTab)->( &(cTab+"_MAT") )+(cTab)->( &(cTab+"_COMPPG") ) == SRA->RA_FILIAL+SRA->RA_MAT+cPerPLA
		aAdd( aRet, { (cTab)->( Recno() ), { (cTab)->( &(cTab+"_FILIAL") ), (cTab)->( &(cTab+"_DATA") ), (cTab)->( &(cTab+"_ORIGEM") ), (cTab)->( &(cTab+"_CODIGO") ), (cTab)->( &(cTab+"_TPLAN") ), (cTab)->( &(cTab+"_TPFORN") ), (cTab)->( &(cTab+"_CODFOR") ), (cTab)->( &(cTab+"_TPPLAN") ), (cTab)->( &(cTab+"_PLANO") ), (cTab)->( &(cTab+"_PD") ), (cTab)->( &(cTab+"_VLRFUN") ), (cTab)->( &(cTab+"_VLREMP") ), (cTab)->( &(cTab+"_COMPPG") ), (cTab)->( &(cTab+"_TIPO") ), (cTab)->( &(cTab+"_INTFOL") ) } } )
		(cTab)->( dbSkip() )
	End
EndIf

RestArea( aArea )

Return aRet 
