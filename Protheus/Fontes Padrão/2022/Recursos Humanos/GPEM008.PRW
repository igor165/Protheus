#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM008.CH"

Static oStructRHR	// Calculo do Plano de Saude
Static aPerAtual
Static cAliasHist := "RHR"
Static cCompCalc  := ""

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    	� GPEM008    � Autor � Mauricio Takakura            � Data � 16/10/11     ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o 	� Calculo do Plano de Saude                                               ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   	� GPEM008()                                                               ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      	� Generico ( DOS e Windows )                                              ���
���������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               			    ���
���������������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � FNC			�  Motivo da Alteracao                        ���
���������������������������������������������������������������������������������������Ĵ��
���Cecilia Car. �15/05/2014�00000014938/2014-TPPCSB     �Incluido o fonte da 11 para a  ���
���             �          �                            �12 e efetuada a limpeza.	    ���
���Esther V.    �07/04/2015�00000009877/2015-TSAZNL     �Alterada ModelDef() para nao   ���
���             �          �                            �buscar periodo atual se chamada���
���             �          �                            �vier do fonte GPEA001.         ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
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
		If cCompFil < cCompCalc .AND. !IsInCallStack("FMANUTCALC") //Se per�odo for menor que per�odo atual e n�o for manuten��o (manuten��o � apenas no per�odo atual), busca dados do hist�rico
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
�����������������������������������������������������������������������Ŀ
�Fun��o    � ViewDef  		�Autor�  Mauricio Takakura� Data �27/09/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Interface com o Usuario                           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEM008                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
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
�����������������������������������������������������������������������Ŀ
�Fun��o    � GpM008SRAStru	�Autor�  Mauricio Takakura� Data �31/10/2010�
�����������������������������������������������������������������������Ĵ
�Descri��o �Selecionar os campos para a estrutura do SRA                �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEM008                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function GpM008SRAStru( cCampo )
	Local lRet := .F.
	
	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_MAT*RA_NOME*RA_ADMISSA' 
		lRet := .T.
	EndIf
	
Return lRet

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � When_NotEdit   �Autor� TOTVS			  � Data �18/05/2012�
�����������������������������������������������������������������������Ĵ
�Descri��o � Permite somente digitacao em inclusao                      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   � < Vide Parametros Formais >								�
�����������������������������������������������������������������������Ĵ
� Uso      � GPEM008                                                    �
�����������������������������������������������������������������������Ĵ
�Parametros� < Vide Parametros Formais >								�
�������������������������������������������������������������������������*/
Static Function When_NotEdit( oStruct )
Local lRet := .F.

If oStruct:GetValue( cAliasHist+"_TPLAN" ) == "1"
	lRet := .T.
Else
	Help( ,, 'HELP',, OemToAnsi( STR0002 + CRLF + STR0003 ), 1, 0 )	// "Somente registros com Tipo de Lan�amento igual a Plano podem ser alterados." ### "Registros com Tipo de Lan�amento Co-participa��o ou Reembolso devem ser alterados em seus lan�amentos originais."
EndIf

Return( lRet )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � RHR_LinhaOK	�Autor� TOTVS			  � Data �18/05/2012�
�����������������������������������������������������������������������Ĵ
�Descri��o � Pos Valid do Model para alterar campo TIPO de 1-Calculado	�
�		   � para 2-Modificado.											�
�����������������������������������������������������������������������Ĵ
�Sintaxe   � < Vide Parametros Formais >								�
�����������������������������������������������������������������������Ĵ
� Uso      � GPEM008                                                    �
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
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
@return lRetorno, logico, se campo far� parte ou n�o da estrutura
/*/
Static Function DefStrRHR(cCampo)

Local lRetorno 	:= .F.
Local nPos		:= At("_", cCampo)

If AllTrim( SubStr(cCampo, nPos ) ) $ '_FILIAL/_MAT/_DATA/_ORIGEM/_CODIGO/_TPLAN/_TPFORN/_CODFOR/_TPPLAN/_PLANO/_PD/_VLRFUN/_VLREMP/_COMPPG/_TIPO/_INTFOL/'
	lRetorno := .T.
EndIf

Return lRetorno

/*/{Protheus.doc} CargaPLA
Carrega registros de c�lculo do plano de sa�de
@author Allyson Luiz Mesashi
@since 08/03/2022
@param oGrid, objeto, grid da estrutura a ser carregada
@param cTab, caracter, alias da tabela de plano de sa�de
@param cPerPLA, caracter, per�odo de c�lculo
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
